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


GREEK_LETTERS = [
    "alpha", "beta", "gamma", "delta", "epsilon", "zeta", "eta", "theta",
    "iota", "kappa", "lambda", "mu", "nu", "xi", "omicron", "pi",
    "rho", "sigma", "tau", "upsilon", "phi", "chi", "psi", "omega",
]


class NvimCodeDiffPlugin:
    name = "nvim-codediff"

    def register(self, config: object) -> PluginRegistration:
        return PluginRegistration(
            tui_actions=[
                TuiAction(
                    name="codediff-main",
                    scope=ActionScope.feature_worktree,
                    key="a",
                    description="CodeDiff vs main",
                    handler=self._handle_codediff_main,
                ),
                TuiAction(
                    name="codediff-head1",
                    scope=ActionScope.feature_worktree,
                    key="e",
                    description="CodeDiff vs HEAD~1",
                    handler=self._handle_codediff_head1,
                ),
                TuiAction(
                    name="codediff-uncommitted",
                    scope=ActionScope.feature_worktree,
                    key="d",
                    description="CodeDiff uncommitted",
                    handler=self._handle_codediff_uncommitted,
                ),
                TuiAction(
                    name="codediff-sibling",
                    scope=ActionScope.feature_worktree,
                    key="f",
                    description="CodeDiff vs closest sibling env",
                    handler=self._handle_sibling_diff,
                ),
                TuiAction(
                    name="codediff-upstream",
                    scope=ActionScope.feature_worktree,
                    key="u",
                    description="CodeDiff local vs remote tracking",
                    handler=self._handle_codediff_upstream,
                ),
            ],
        )

    def _handle_codediff_main(self, ctx: FeatureWorktreeContext) -> None:
        repo_path = str(ctx.worktree.path)
        main_branch = ctx.worktree.workspace.main_branch
        self._launch_codediff(repo_path, f"origin/{main_branch}")

    def _handle_codediff_head1(self, ctx: FeatureWorktreeContext) -> None:
        repo_path = str(ctx.worktree.path)
        self._launch_codediff(repo_path, "HEAD~1")

    def _handle_codediff_uncommitted(self, ctx: FeatureWorktreeContext) -> None:
        repo_path = str(ctx.worktree.path)
        self._launch_codediff(repo_path, target=None)

    def _handle_codediff_upstream(self, ctx: FeatureWorktreeContext) -> None:
        """Diff what was last reviewed (local HEAD) against the remote tracking branch.

        Uses CodeDiff's triple-dot (merge-base) form `HEAD...@{u}`: the old side is
        the merge-base of HEAD and the upstream, the new side is the upstream tip.
        That shows only the commits the remote gained since we diverged, ignoring
        any local-only commits we have on top — the natural "review the new commits
        they pushed" diff.
        """
        repo_path = str(ctx.worktree.path)

        upstream = self._upstream_ref(repo_path)
        if upstream is None:
            self._notify_nvim("No upstream tracking branch configured for this worktree")
            return

        behind = self._count(repo_path, f"HEAD..{upstream}")
        if behind == 0:
            self._notify_nvim(f"Already up to date with {upstream} — nothing new to review")
            return

        self._launch_codediff(
            repo_path,
            target=None,
            diff_spec="HEAD...@{u}",
            notify=f"Reviewing {behind} new commit(s) on {upstream}",
        )

    @staticmethod
    def _upstream_ref(repo_path: str) -> str | None:
        """Return the symbolic upstream ref (e.g. 'origin/main'), or None if unset."""
        try:
            out = subprocess.check_output(
                ["git", "-C", repo_path, "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}"],
                stderr=subprocess.DEVNULL,
            )
        except subprocess.CalledProcessError:
            return None
        ref = out.decode().strip()
        return ref or None

    @staticmethod
    def _count(repo_path: str, rev_range: str) -> int:
        """Commit count for a rev range; 0 on any git error so callers can no-op."""
        try:
            out = subprocess.check_output(
                ["git", "-C", repo_path, "rev-list", "--count", rev_range],
                stderr=subprocess.DEVNULL,
            )
            return int(out.decode().strip())
        except (subprocess.CalledProcessError, ValueError):
            return 0

    def _handle_sibling_diff(self, ctx: FeatureWorktreeContext) -> None:
        repo_path = str(ctx.worktree.path)
        siblings = self._discover_siblings(ctx)
        target = self._pick_closest_sibling(repo_path, siblings) if siblings else None

        if target is None:
            self._notify_nvim("No sibling environments with distinct commits found")
            return

        self._launch_codediff(
            repo_path,
            target,
            notify=f"Diffing against sibling environment: {target}",
        )

    def _discover_siblings(self, ctx: FeatureWorktreeContext) -> list[str]:
        root = Path(ctx.worktree.workspace.root_path)
        repo_name = ctx.worktree.repository.name
        current = ctx.worktree.environment.name
        siblings: list[str] = []
        for letter in GREEK_LETTERS:
            if letter == current:
                continue
            if (root / letter / repo_name).is_dir():
                siblings.append(letter)
        return siblings

    def _pick_closest_sibling(self, repo_path: str, siblings: list[str]) -> str | None:
        """Pick the sibling branch closest to HEAD.

        Priority 1: a strict ancestor of HEAD, with the smallest ahead count.
        Fallback:   any sibling with the smallest symmetric difference to HEAD.
        """
        best_ancestor: tuple[int, str] | None = None
        best_any: tuple[int, str] | None = None
        devnull = subprocess.DEVNULL

        for s in siblings:
            verify = subprocess.run(
                ["git", "-C", repo_path, "rev-parse", "--verify", "--quiet", s],
                stdout=devnull, stderr=devnull,
            )
            if verify.returncode != 0:
                continue
            try:
                ahead = int(subprocess.check_output(
                    ["git", "-C", repo_path, "rev-list", "--count", f"{s}..HEAD"],
                    stderr=devnull,
                ).decode().strip())
                behind = int(subprocess.check_output(
                    ["git", "-C", repo_path, "rev-list", "--count", f"HEAD..{s}"],
                    stderr=devnull,
                ).decode().strip())
            except (subprocess.CalledProcessError, ValueError):
                continue
            if ahead == 0 and behind == 0:
                continue
            if behind == 0 and ahead > 0:
                if best_ancestor is None or ahead < best_ancestor[0]:
                    best_ancestor = (ahead, s)
            total = ahead + behind
            if best_any is None or total < best_any[0]:
                best_any = (total, s)

        if best_ancestor is not None:
            return best_ancestor[1]
        if best_any is not None:
            return best_any[1]
        return None

    def _launch_codediff(
        self,
        repo_path: str,
        target: str | None,
        notify: str | None = None,
        diff_spec: str | None = None,
    ) -> None:
        sock = self._find_nvim_socket()
        if sock is None:
            self._launch_neovide_codediff(repo_path, target, notify, diff_spec)
            return

        devnull = subprocess.DEVNULL
        server = ["nvim", "--server", sock]
        try:
            # CodeDiff resolves the git root from getcwd(), so we need tcd
            # set before invoking it. However, CodeDiff is async — it returns
            # immediately and creates its own tab later via vim.schedule. We
            # can't close the temp tab inline because the async callbacks
            # would lose the tcd context. Instead, a one-shot TabNew autocmd
            # fires when CodeDiff opens its tab: it closes the temp tab and
            # sets tcd on the new CodeDiff tab.
            codediff_arg = diff_spec if diff_spec else (f"{target}..." if target else "")
            cmd = (
                f"<C-\\><C-n>"
                f":tabnew | tcd {repo_path}<CR>"
                f":autocmd TabNew * ++once exe tabpagenr()-1 .. 'tabclose' | tcd {repo_path}<CR>"
                f":CodeDiff {codediff_arg}<CR>"
            )
            if notify:
                cmd += f":echom '{self._vim_single_quote_escape(notify)}'<CR>"
            subprocess.run(
                [*server, "--remote-send", cmd],
                stdin=devnull, stdout=devnull, stderr=devnull,
                timeout=5,
            )
            subprocess.Popen(["open", "-a", "Neovide"], stdin=devnull, stdout=devnull, stderr=devnull)
        except (FileNotFoundError, subprocess.TimeoutExpired):
            self._launch_neovide_codediff(repo_path, target, notify)

    def _notify_nvim(self, message: str) -> None:
        msg = self._vim_single_quote_escape(message)
        sock = self._find_nvim_socket()
        if sock is None:
            # No live nvim to send to — launch Neovide purely to surface the
            # message, otherwise the action (e.g. `u` when already up to date)
            # is silently a no-op. A VimEnter autocmd echoes after startup so
            # the message survives the intro screen.
            self._notify_neovide(msg)
            return
        devnull = subprocess.DEVNULL
        try:
            subprocess.run(
                ["nvim", "--server", sock, "--remote-send",
                 f"<C-\\><C-n>:echohl WarningMsg | echom '{msg}' | echohl None<CR>"],
                stdin=devnull, stdout=devnull, stderr=devnull,
                timeout=5,
            )
            subprocess.Popen(["open", "-a", "Neovide"], stdin=devnull, stdout=devnull, stderr=devnull)
        except (FileNotFoundError, subprocess.TimeoutExpired):
            self._notify_neovide(msg)

    def _notify_neovide(self, escaped_msg: str) -> None:
        """Launch Neovide solely to display an already-escaped warning message."""
        devnull = subprocess.DEVNULL
        echo = f"echohl WarningMsg | echom '{escaped_msg}' | echohl None"
        subprocess.Popen(
            ["neovide", "--", "-c", f"autocmd VimEnter * ++once {echo}"],
            stdin=devnull, stdout=devnull, stderr=devnull,
        )

    def _find_nvim_socket(self) -> str | None:
        tmpdir = os.environ.get("TMPDIR", "/tmp")
        nvim_dir = Path(tmpdir) / f"nvim.{os.environ.get('USER', '')}"
        if not nvim_dir.exists():
            return None

        sockets = sorted(nvim_dir.rglob("nvim.*"), key=lambda p: p.stat().st_mtime, reverse=True)
        for sock in sockets:
            if not sock.is_socket():
                continue
            # Liveness check via direct socket connect — does not require nvim
            # to be idle, so a partial command-line entry, pending mapping, or
            # operator-pending state won't make a live nvim look dead.
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

    def _launch_neovide_codediff(
        self,
        repo_path: str,
        target: str | None,
        notify: str | None = None,
        diff_spec: str | None = None,
    ) -> None:
        devnull = subprocess.DEVNULL
        codediff_arg = diff_spec if diff_spec else (f"{target}..." if target else "")
        args = ["neovide", "--", "--cmd", f"cd {repo_path}",
                "-c", "autocmd TabNew * ++once 1tabclose",
                "-c", f"CodeDiff {codediff_arg}"]
        if notify:
            args.extend(["-c", f"echom '{self._vim_single_quote_escape(notify)}'"])
        subprocess.Popen(args, stdin=devnull, stdout=devnull, stderr=devnull)

    @staticmethod
    def _vim_single_quote_escape(s: str) -> str:
        # In Vim single-quoted strings, a literal single quote is written as ''.
        return s.replace("'", "''")


def create_plugin() -> NvimCodeDiffPlugin:
    return NvimCodeDiffPlugin()
