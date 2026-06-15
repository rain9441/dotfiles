"""Dashboard plugin: open a worktree / repo in Neovim (cd + restore session).

Bound to "o" on the feature-worktree grid and "O" on the standalone-repo panel.
(Both screens install every scope's plugin keys at once, so the two actions
can't share a single key — see the resolver's collision check.)
Unlike `nvim-codediff` (which opens a diff), this just switches Neovim's working
directory into the selected repo and loads a saved session if one exists.

The cd-and-restore-session behaviour is delegated to winter.nvim's public API,
`require('winter').switch_to(path, label)`, so it honours the user's own
`use_sessions` / `create_sessions` / `cd_command` / `session_dir` config rather
than reimplementing session handling here.
"""

from __future__ import annotations

import os
import socket as _socket
import subprocess
from pathlib import Path

from winter_cli.plugins.types import (
    ActionScope,
    FeatureWorktreeContext,
    PluginRegistration,
    TuiAction,
)


class NvimOpenPlugin:
    name = "nvim-open"

    def register(self, config: object) -> PluginRegistration:
        actions = [
            TuiAction(
                name="nvim-open-worktree",
                scope=ActionScope.feature_worktree,
                key="o",
                description="Open in Neovim",
                handler=self._handle_open_worktree,
            ),
        ]
        # The standalone-repository action scope was added after some installed
        # CLIs; only register the standalone action when the running CLI knows
        # the scope, so this plugin loads cleanly on older winter builds too.
        if hasattr(ActionScope, "standalone_repository"):
            actions.append(
                TuiAction(
                    name="nvim-open-standalone",
                    scope=ActionScope.standalone_repository,
                    key="O",
                    description="Open in Neovim",
                    handler=self._handle_open_standalone,
                )
            )
        return PluginRegistration(tui_actions=actions)

    def _handle_open_worktree(self, ctx: FeatureWorktreeContext) -> None:
        wt = ctx.worktree
        label = f"{wt.environment.name}/{wt.repository.name}"
        self._launch_open(str(wt.path), label)

    def _handle_open_standalone(self, ctx: "StandaloneRepoContext") -> None:
        repo = ctx.repo
        self._launch_open(str(repo.path), repo.name)

    def _launch_open(self, repo_path: str, label: str) -> None:
        """cd a running Neovim into repo_path (restoring a session), else spawn one."""
        sock = self._find_nvim_socket()
        if sock is None:
            self._launch_neovide_open(repo_path, label)
            return

        devnull = subprocess.DEVNULL
        switch = self._switch_to_lua(repo_path, label)
        try:
            cmd = f"<C-\\><C-n>:lua {switch}<CR>"
            subprocess.run(
                ["nvim", "--server", sock, "--remote-send", cmd],
                stdin=devnull, stdout=devnull, stderr=devnull,
                timeout=5,
            )
            subprocess.Popen(["open", "-a", "Neovide"], stdin=devnull, stdout=devnull, stderr=devnull)
        except (FileNotFoundError, subprocess.TimeoutExpired):
            self._launch_neovide_open(repo_path, label)

    def _launch_neovide_open(self, repo_path: str, label: str) -> None:
        devnull = subprocess.DEVNULL
        # -c runs after plugins load (winter.nvim is lazy=false), so switch_to is available.
        args = ["neovide", "--", "-c", f"lua {self._switch_to_lua(repo_path, label)}"]
        subprocess.Popen(args, stdin=devnull, stdout=devnull, stderr=devnull)

    def _switch_to_lua(self, repo_path: str, label: str) -> str:
        return (
            "require('winter').switch_to("
            f"'{self._lua_single_quote_escape(repo_path)}', "
            f"'{self._lua_single_quote_escape(label)}')"
        )

    @staticmethod
    def _lua_single_quote_escape(s: str) -> str:
        # Escape for a Lua single-quoted string literal: backslash then quote.
        return s.replace("\\", "\\\\").replace("'", "\\'")

    def _find_nvim_socket(self) -> str | None:
        tmpdir = os.environ.get("TMPDIR", "/tmp")
        nvim_dir = Path(tmpdir) / f"nvim.{os.environ.get('USER', '')}"
        if not nvim_dir.exists():
            return None

        sockets = sorted(nvim_dir.rglob("nvim.*"), key=lambda p: p.stat().st_mtime, reverse=True)
        for sock in sockets:
            if not sock.is_socket():
                continue
            if self._socket_is_live(str(sock)):
                return str(sock)
        return None

    @staticmethod
    def _socket_is_live(path: str) -> bool:
        s = _socket.socket(_socket.AF_UNIX, _socket.SOCK_STREAM)
        s.settimeout(0.2)
        try:
            s.connect(path)
            return True
        except (OSError, _socket.timeout):
            return False
        finally:
            s.close()


def create_plugin() -> NvimOpenPlugin:
    return NvimOpenPlugin()
