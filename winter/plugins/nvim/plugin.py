"""Dashboard plugin: Neovim integration — open worktrees/repos and run CodeDiff.

Merged from the former `nvim-open` and `nvim-codediff` plugins. They each
carried their own copy of the Neovim launch/reuse machinery (socket discovery,
liveness check, window raise), and the copies drifted: a Linux fix applied to
one left the other still spawning a fresh Neovide every time. Keeping that
machinery in one place is the whole point of the merge.

Actions (all on the feature-worktree grid unless noted):
  o  open the worktree in Neovim (cd + restore session)
  O  open a standalone repository in Neovim (standalone-repo panel)
  a  CodeDiff vs origin/<main>
  e  CodeDiff vs HEAD~1
  d  CodeDiff uncommitted
  f  CodeDiff vs closest sibling environment
  u  CodeDiff local vs remote tracking branch

The cd-and-restore-session behaviour (the `o`/`O` actions) is delegated to
winter.nvim's public API, `require('winter').switch_to(path, label)`, so it
honours the user's own `use_sessions` / `create_sessions` / `cd_command` /
`session_dir` config rather than reimplementing session handling here.
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


GREEK_LETTERS = [
    "alpha", "beta", "gamma", "delta", "epsilon", "zeta", "eta", "theta",
    "iota", "kappa", "lambda", "mu", "nu", "xi", "omicron", "pi",
    "rho", "sigma", "tau", "upsilon", "phi", "chi", "psi", "omega",
]


class _MacPlatform:
    """How to bring an existing Neovide window forward on macOS."""

    def raise_window_cmd(self) -> list[str]:
        return ["open", "-a", "Neovide"]


class _KdePlatform:
    """How to bring an existing Neovide window forward on Linux/KDE.

    Mirrors the raise used in linux/kde/raise-or-run.sh.
    """

    def raise_window_cmd(self) -> list[str]:
        return ["kdotool", "search", "Neovide", "windowactivate", "%1"]


class NvimPlugin:
    name = "nvim"

    def register(self, config: object) -> PluginRegistration:
        actions = [
            TuiAction(
                name="nvim-open-worktree",
                scope=ActionScope.feature_worktree,
                key="o",
                description="Open in Neovim",
                handler=self._handle_open_worktree,
            ),
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

    # ------------------------------------------------------------------ #
    # Shared Neovim server discovery / control                           #
    # ------------------------------------------------------------------ #

    def _find_nvim_socket(self) -> "tuple[str, _MacPlatform | _KdePlatform] | None":
        # Neovim's default server lives in stdpath('run'), which differs by OS:
        #   Linux: $XDG_RUNTIME_DIR        → socket sits there as nvim.<pid>.0
        #   macOS: $TMPDIR/nvim.<user>/    → socket nested a level down
        # Each root is paired with the platform whose Neovim writes there, so the
        # root that yields a live socket also tells us how to raise its window —
        # platform detection falls out of discovery, no separate sys.platform
        # check. Probing the union stays tolerant of mixed setups (e.g.
        # XDG_RUNTIME_DIR set on a Mac), and the live instance we actually talk
        # to picks the matching raise strategy.
        #
        # (root, platform, recursive). The Linux socket sits at the top of
        # $XDG_RUNTIME_DIR, so glob it non-recursively — that dir also holds FUSE
        # mounts (gvfs, the flatpak doc portal) that an rglob could hang or throw
        # on. The macOS socket is nested under $TMPDIR/nvim.<user>/, so recurse.
        roots: list[tuple[Path, _MacPlatform | _KdePlatform, bool]] = []
        xdg = os.environ.get("XDG_RUNTIME_DIR")
        if xdg:
            roots.append((Path(xdg), _KdePlatform(), False))
        tmpdir = os.environ.get("TMPDIR") or "/tmp"
        roots.append((Path(tmpdir) / f"nvim.{os.environ.get('USER', '')}", _MacPlatform(), True))

        sockets: list[tuple[Path, _MacPlatform | _KdePlatform]] = []
        for root, platform, recursive in roots:
            if not root.exists():
                continue
            try:
                globber = root.rglob if recursive else root.glob
                found = list(globber("nvim.*"))
            except OSError:
                # A wedged FUSE mount or permission error under the root must
                # not take down discovery — skip this root and try the next.
                continue
            sockets.extend((sock, platform) for sock in found)
        sockets.sort(key=lambda pair: pair[0].stat().st_mtime, reverse=True)

        for sock, platform in sockets:
            if not sock.is_socket():
                continue
            # Liveness check via direct socket connect — does not require nvim
            # to be idle, so a partial command-line entry, pending mapping, or
            # operator-pending state won't make a live nvim look dead.
            if self._socket_is_live(str(sock)):
                return str(sock), platform
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

    def _raise_neovide(self, platform: "_MacPlatform | _KdePlatform") -> None:
        """Bring an already-running Neovide window to the foreground.

        Best-effort and always called OUTSIDE the remote-send try block: a
        missing window-manager helper must never fall through to spawning a
        second Neovide.
        """
        devnull = subprocess.DEVNULL
        try:
            subprocess.Popen(
                platform.raise_window_cmd(),
                stdin=devnull, stdout=devnull, stderr=devnull,
            )
        except (FileNotFoundError, OSError):
            pass

    # ------------------------------------------------------------------ #
    # open-in-Neovim (o / O)                                             #
    # ------------------------------------------------------------------ #

    def _handle_open_worktree(self, ctx: FeatureWorktreeContext) -> None:
        wt = ctx.worktree
        label = f"{wt.environment.name}/{wt.repository.name}"
        self._launch_open(str(wt.path), label)

    def _handle_open_standalone(self, ctx: "StandaloneRepoContext") -> None:
        repo = ctx.repo
        self._launch_open(str(repo.path), repo.name)

    def _launch_open(self, repo_path: str, label: str) -> None:
        """cd a running Neovim into repo_path (restoring a session), else spawn one."""
        found = self._find_nvim_socket()
        if found is None:
            self._launch_neovide_open(repo_path, label)
            return
        sock, platform = found

        devnull = subprocess.DEVNULL
        switch = self._switch_to_lua(repo_path, label)
        cmd = f"<C-\\><C-n>:lua {switch}<CR>"
        try:
            subprocess.run(
                ["nvim", "--server", sock, "--remote-send", cmd],
                stdin=devnull, stdout=devnull, stderr=devnull,
                timeout=5,
            )
        except (FileNotFoundError, subprocess.TimeoutExpired):
            # Couldn't reach the running instance after all — spawn a fresh one.
            self._launch_neovide_open(repo_path, label)
            return

        self._raise_neovide(platform)

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

    # ------------------------------------------------------------------ #
    # CodeDiff (a / e / d / f / u)                                       #
    # ------------------------------------------------------------------ #

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
        found = self._find_nvim_socket()
        if found is None:
            self._launch_neovide_codediff(repo_path, target, notify, diff_spec)
            return
        sock, platform = found

        devnull = subprocess.DEVNULL
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
                ["nvim", "--server", sock, "--remote-send", cmd],
                stdin=devnull, stdout=devnull, stderr=devnull,
                timeout=5,
            )
        except (FileNotFoundError, subprocess.TimeoutExpired):
            self._launch_neovide_codediff(repo_path, target, notify, diff_spec)
            return

        self._raise_neovide(platform)

    def _notify_nvim(self, message: str) -> None:
        msg = self._vim_single_quote_escape(message)
        found = self._find_nvim_socket()
        if found is None:
            # No live nvim to send to — launch Neovide purely to surface the
            # message, otherwise the action (e.g. `u` when already up to date)
            # is silently a no-op. A VimEnter autocmd echoes after startup so
            # the message survives the intro screen.
            self._notify_neovide(msg)
            return
        sock, platform = found
        devnull = subprocess.DEVNULL
        try:
            subprocess.run(
                ["nvim", "--server", sock, "--remote-send",
                 f"<C-\\><C-n>:echohl WarningMsg | echom '{msg}' | echohl None<CR>"],
                stdin=devnull, stdout=devnull, stderr=devnull,
                timeout=5,
            )
        except (FileNotFoundError, subprocess.TimeoutExpired):
            self._notify_neovide(msg)
            return

        self._raise_neovide(platform)

    def _notify_neovide(self, escaped_msg: str) -> None:
        """Launch Neovide solely to display an already-escaped warning message."""
        devnull = subprocess.DEVNULL
        echo = f"echohl WarningMsg | echom '{escaped_msg}' | echohl None"
        subprocess.Popen(
            ["neovide", "--", "-c", f"autocmd VimEnter * ++once {echo}"],
            stdin=devnull, stdout=devnull, stderr=devnull,
        )

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


def create_plugin() -> NvimPlugin:
    return NvimPlugin()
