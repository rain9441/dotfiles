"""Dashboard plugin: Neovim integration — open worktrees/repos and run CodeDiff.

Merged from the former `nvim-open` and `nvim-codediff` plugins. They each
carried their own copy of the Neovim launch/reuse machinery (socket discovery,
liveness check, window raise), and the copies drifted: a Linux fix applied to
one left the other still spawning a fresh Neovide every time. Keeping that
machinery in one place is the whole point of the merge.

Actions (all on the feature-worktree grid unless noted):
  o  open in Neovim (cd + restore session) — the focused worktree, or a
     standalone repository when the standalone panel is focused. On winter
     builds without multi-scope action support this splits into two bindings:
     `o` for a worktree and `O` for a standalone repository.
  a  CodeDiff vs origin/<main>
  e  CodeDiff vs HEAD~1
  d  CodeDiff uncommitted
  f  CodeDiff vs closest sibling environment
  u  CodeDiff local vs remote tracking branch
  A  CodeDiff whole feature env vs main (merge-base), all repos
  S  CodeDiff whole feature env vs master (merge-base), all repos
  E  CodeDiff whole feature env uncommitted (working tree), all repos

The A/S/E actions aggregate every project-repo worktree in the focused
environment into one multi-repo CodeDiff session. A/S use codediff's
`diff_repos` Lua API: each repo is diffed from its merge-base with the target
branch (origin/main for A, origin/master for S) to HEAD — the committed work
the feature env is ahead on. This is a revision-to-revision diff: uncommitted
working-tree changes are NOT included, and a repo lacking the target branch is
skipped. E is the working-tree counterpart (the env-wide version of `d`): it
uses codediff's `diff_repos_uncommitted` Lua API to aggregate every worktree's
dirty state (staged + unstaged + untracked + conflicts), skipping repos with no
changes. All three prefer the env worktree list carried on the action context
(the winter env-context payload) and fall back to enumerating the environment
directory on older winter-cli builds.

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

try:
    # Multi-scope TuiActions and the ActionInvocation handler argument landed
    # together (winter#58). Their presence means one action can span the
    # feature-worktree grid and the standalone-repo panel under a single key.
    from winter_cli.plugins.types import ActionInvocation  # noqa: F401

    _SUPPORTS_MULTISCOPE = True
except ImportError:  # older winter build — one scope per action
    _SUPPORTS_MULTISCOPE = False


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
            *self._open_actions(),
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
            TuiAction(
                name="codediff-env-main",
                scope=ActionScope.feature_worktree,
                key="A",
                description="CodeDiff whole env vs main",
                handler=self._handle_codediff_env_main,
            ),
            TuiAction(
                name="codediff-env-master",
                scope=ActionScope.feature_worktree,
                key="S",
                description="CodeDiff whole env vs master",
                handler=self._handle_codediff_env_master,
            ),
            TuiAction(
                name="codediff-env-uncommitted",
                scope=ActionScope.feature_worktree,
                key="E",
                description="CodeDiff whole env uncommitted",
                handler=self._handle_codediff_env_uncommitted,
            ),
        ]
        return PluginRegistration(tui_actions=actions)

    def _open_actions(self) -> list[TuiAction]:
        """Build the open-in-Neovim action(s).

        On a winter build with multi-scope action support (winter#58), one `o`
        action spans both the feature-worktree grid and the standalone-repo
        panel — winter routes the keypress to whichever area is focused. On
        older builds a single action can carry only one scope, so fall back to
        two bindings: `o` for a worktree and `O` for a standalone repo. The
        standalone scope itself predates this, so it is also gated on the enum
        member existing, keeping the plugin loadable on the oldest CLIs.
        """
        has_standalone = hasattr(ActionScope, "standalone_repository")
        if _SUPPORTS_MULTISCOPE and has_standalone:
            return [
                TuiAction(
                    name="nvim-open",
                    scope=[ActionScope.feature_worktree, ActionScope.standalone_repository],
                    key="o",
                    description="Open in Neovim",
                    handler=self._handle_open,
                )
            ]
        open_actions = [
            TuiAction(
                name="nvim-open-worktree",
                scope=ActionScope.feature_worktree,
                key="o",
                description="Open in Neovim",
                handler=self._handle_open_worktree,
            )
        ]
        if has_standalone:
            open_actions.append(
                TuiAction(
                    name="nvim-open-standalone",
                    scope=ActionScope.standalone_repository,
                    key="O",
                    description="Open in Neovim",
                    handler=self._handle_open_standalone,
                )
            )
        return open_actions

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

        # Two-tier preference, both honouring the newest-first mtime sort above:
        #   1. the user's Neovide GUI (newest), else
        #   2. any nvim with an attached UI (newest) — a terminal nvim / nvim-qt.
        # A headless nvim has no UI, so it can never win either tier. This is the
        # whole fix: plugin test runners (busted/plenary) spawn headless nvims
        # whose freshly-created sockets otherwise top the mtime sort and steal
        # the action. We must scan all sockets before falling back to tier 2, so
        # an older Neovide still beats a newer UI-attached terminal nvim.
        ui_fallback: "tuple[str, _MacPlatform | _KdePlatform] | None" = None
        for sock, platform in sockets:
            if not sock.is_socket():
                continue
            # Liveness check via direct socket connect — does not require nvim
            # to be idle, so a partial command-line entry, pending mapping, or
            # operator-pending state won't make a live nvim look dead. Used as a
            # cheap pre-filter so we don't spend the remote-expr timeout on a
            # stale socket file.
            if not self._socket_is_live(str(sock)):
                continue
            kind = self._probe_socket(str(sock))
            if kind == "neovide":
                return str(sock), platform
            if kind == "ui" and ui_fallback is None:
                ui_fallback = (str(sock), platform)
        return ui_fallback

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

    @staticmethod
    def _probe_socket(path: str) -> "str | None":
        """Classify the nvim on `path`: "neovide", "ui" (attached but not Neovide), or None.

        Neovide injects the `g:neovide` global into its embedded nvim on startup;
        a headless test nvim has neither that global nor any attached UI. One
        remote-expr asks both questions at once — `exists('g:neovide')` and
        whether `nvim_list_uis()` is non-empty — yielding a 2-char string like
        "10". The call fails outright if the instance can't be reached, so this
        doubles as a second liveness gate. Cross-platform: it asks nvim itself
        rather than inspecting the process tree, so it works the same on Linux
        and macOS.
        """
        try:
            result = subprocess.run(
                ["nvim", "--server", path, "--remote-expr",
                 "exists('g:neovide') . (!empty(nvim_list_uis()))"],
                stdin=subprocess.DEVNULL,
                capture_output=True,
                timeout=2,
            )
        except (FileNotFoundError, subprocess.TimeoutExpired):
            return None
        out = result.stdout.strip()
        if out[:1] == b"1":
            return "neovide"
        if out[1:2] == b"1":
            return "ui"
        return None

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

    def _handle_open(self, inv: "ActionInvocation") -> None:
        """Open whichever area is focused — a feature worktree or a standalone repo.

        Multi-scope dispatch hands us an ActionInvocation; branch on the
        originating scope and read the selection from the type-checked
        `inv.context`. Used only on winter builds with multi-scope support; the
        per-scope handlers below remain for the older two-binding fallback.
        """
        if inv.scope is ActionScope.standalone_repository:
            repo = inv.context.repo
            self._launch_open(str(repo.path), repo.name)
        else:
            wt = inv.context.worktree
            self._launch_open(str(wt.path), f"{wt.environment.name}/{wt.repository.name}")

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

    # ------------------------------------------------------------------ #
    # Whole-environment multi-repo CodeDiff (A / S)                       #
    # ------------------------------------------------------------------ #

    def _handle_codediff_env_main(self, ctx: FeatureWorktreeContext) -> None:
        self._handle_codediff_env(ctx, "main")

    def _handle_codediff_env_master(self, ctx: FeatureWorktreeContext) -> None:
        self._handle_codediff_env(ctx, "master")

    def _handle_codediff_env_uncommitted(self, ctx: FeatureWorktreeContext) -> None:
        """Aggregate every project-repo worktree in the focused env into ONE
        multi-repo CodeDiff of the WORKING-TREE (dirty) state — staged,
        unstaged, untracked, and conflicted changes across the whole env, before
        anything is committed.

        The env-wide counterpart of the per-worktree `d` action. Unlike A/S
        (committed merge-base..HEAD ranges), this is a pure working-tree diff:
        every worktree root is passed as-is to codediff's
        `diff_repos_uncommitted` Lua API, which tags each file with its origin
        repo and omits repos that have no dirty files — so the explorer shows
        only the worktrees that actually changed.
        """
        worktrees = self._env_worktree_roots(ctx)
        if not worktrees:
            self._notify_nvim("No feature-environment worktrees found for multi-repo diff")
            return

        roots = [root for root, _repo_main in worktrees]
        notify = f"Multi-repo uncommitted diff: {len(roots)} worktree(s)"
        self._launch_codediff_repos_uncommitted(roots, notify)

    def _handle_codediff_env(self, ctx: FeatureWorktreeContext, main_branch: str) -> None:
        """Aggregate every project-repo worktree in the focused env into ONE
        multi-repo CodeDiff, each repo diffed from its merge-base with
        origin/<main_branch> to HEAD — the committed work the env is ahead on.

        This is a revision-to-revision diff: uncommitted working-tree changes
        are NOT included. A repo that lacks origin/<main_branch> (e.g. a `main`
        repo when diffing vs `master`), or whose merge-base can't be resolved,
        is skipped so one repo doesn't abort the rest.
        """
        worktrees = self._env_worktree_roots(ctx)
        if not worktrees:
            self._notify_nvim("No feature-environment worktrees found for multi-repo diff")
            return

        specs: list[tuple[str, str]] = []
        skipped = 0
        for root, _repo_main in worktrees:
            base = self._merge_base_with(root, main_branch)
            if base is None:
                skipped += 1
                continue
            specs.append((root, base))

        if not specs:
            self._notify_nvim(f"No repos with an origin/{main_branch} base for multi-repo diff")
            return

        notify = f"Multi-repo diff: {len(specs)} repo(s) vs {main_branch}"
        if skipped:
            notify += f" ({skipped} skipped — no origin/{main_branch})"
        self._launch_codediff_repos(specs, notify)

    def _env_worktree_roots(self, ctx: FeatureWorktreeContext) -> list[tuple[str, str | None]]:
        """Return (worktree_path, repo_main_branch_or_None) for every project
        repo in the focused environment.

        Prefers the env worktree list carried on the action context (winter
        builds that enrich FeatureWorktreeContext with `environment_worktrees`).
        Falls back to enumerating real git worktrees directly under the env
        directory on older winter-cli builds that don't carry the payload.
        """
        env_worktrees = getattr(ctx, "environment_worktrees", None)
        worktrees = getattr(env_worktrees, "worktrees", None)
        if worktrees:
            out: list[tuple[str, str | None]] = []
            for wt in worktrees:
                repo_main = getattr(getattr(wt, "repository", None), "main_branch", None)
                out.append((str(wt.path), repo_main))
            return out

        # Fallback: enumerate the environment directory. Skip symlinks (winter
        # seeds convenience symlinks like nvim-dev-* into env dirs) and anything
        # that isn't a git worktree.
        wt = getattr(ctx, "worktree", None)
        if wt is None:
            return []
        env_path = Path(wt.environment.path)
        out = []
        try:
            children = sorted(env_path.iterdir())
        except OSError:
            return []
        for child in children:
            if child.is_symlink() or not child.is_dir():
                continue
            if not (child / ".git").exists():
                continue
            out.append((str(child), None))
        return out

    @staticmethod
    def _merge_base_with(root: str, branch: str) -> str | None:
        """The merge-base of origin/<branch> and HEAD, or None if origin/<branch>
        doesn't exist in this repo or the merge-base can't be computed."""
        try:
            base = subprocess.check_output(
                ["git", "-C", root, "merge-base", f"origin/{branch}", "HEAD"],
                stderr=subprocess.DEVNULL,
            ).decode().strip()
            return base or None
        except subprocess.CalledProcessError:
            return None

    def _launch_codediff_repos(
        self, specs: list[tuple[str, str]], notify: str | None = None
    ) -> None:
        """Open a multi-repo CodeDiff via codediff's `diff_repos` Lua API.

        Unlike the single-repo `:CodeDiff` path, diff_repos takes absolute repo
        roots, so no tcd dance is needed — the session resolves each side
        against its own root. Layout follows the user's codediff config (same as
        the a/e/d/f/u actions) and is toggleable in-session. Reuses the shared
        running-instance / fresh-Neovide launch machinery.
        """
        self._dispatch_codediff_lua(self._diff_repos_lua(specs), notify)

    def _launch_codediff_repos_uncommitted(
        self, roots: list[str], notify: str | None = None
    ) -> None:
        """Open a multi-repo working-tree CodeDiff via codediff's
        `diff_repos_uncommitted` Lua API. Same launch machinery as
        `_launch_codediff_repos`; only the Lua entry point differs."""
        self._dispatch_codediff_lua(self._diff_repos_uncommitted_lua(roots), notify)

    def _dispatch_codediff_lua(self, lua: str, notify: str | None = None) -> None:
        """Run a codediff Lua expression in the running Neovim instance, or spawn
        a fresh Neovide if none is live. Shared by every multi-repo launcher."""
        found = self._find_nvim_socket()
        if found is None:
            self._launch_neovide_lua(lua, notify)
            return
        sock, platform = found

        devnull = subprocess.DEVNULL
        cmd = f"<C-\\><C-n>:lua {lua}<CR>"
        if notify:
            cmd += f":echom '{self._vim_single_quote_escape(notify)}'<CR>"
        try:
            subprocess.run(
                ["nvim", "--server", sock, "--remote-send", cmd],
                stdin=devnull, stdout=devnull, stderr=devnull,
                timeout=5,
            )
        except (FileNotFoundError, subprocess.TimeoutExpired):
            self._launch_neovide_lua(lua, notify)
            return

        self._raise_neovide(platform)

    def _diff_repos_lua(self, specs: list[tuple[str, str]]) -> str:
        """Build the `require('codediff').diff_repos({...})` Lua expression.
        target is HEAD for every spec — the merge-base..HEAD range is the
        committed feature work the env is ahead on."""
        parts = []
        for root, base in specs:
            parts.append(
                "{root='%s', base='%s', target='HEAD'}"
                % (self._lua_single_quote_escape(root), self._lua_single_quote_escape(base))
            )
        specs_lua = "{" + ", ".join(parts) + "}"
        return f"require('codediff').diff_repos({specs_lua})"

    def _diff_repos_uncommitted_lua(self, roots: list[str]) -> str:
        """Build the `require('codediff').diff_repos_uncommitted({...})` Lua
        expression. Each entry is a bare root; codediff defaults the repo label
        to the basename and skips repos with no working-tree changes."""
        parts = [
            "{root='%s'}" % self._lua_single_quote_escape(root)
            for root in roots
        ]
        roots_lua = "{" + ", ".join(parts) + "}"
        return f"require('codediff').diff_repos_uncommitted({roots_lua})"

    def _launch_neovide_lua(self, lua: str, notify: str | None = None) -> None:
        """Spawn a fresh Neovide and run a Lua expression after plugins load.

        diff_repos opens its own tab asynchronously, so a one-shot TabNew
        autocmd closes the initial empty tab (mirrors _launch_neovide_codediff).
        """
        devnull = subprocess.DEVNULL
        args = [
            "neovide", "--",
            "-c", "autocmd TabNew * ++once 1tabclose",
            "-c", f"lua {lua}",
        ]
        if notify:
            args.extend(["-c", f"echom '{self._vim_single_quote_escape(notify)}'"])
        subprocess.Popen(args, stdin=devnull, stdout=devnull, stderr=devnull)

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
