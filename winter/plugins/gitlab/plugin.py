from __future__ import annotations

import logging
import re
import sys
import webbrowser
from pathlib import Path
from typing import TYPE_CHECKING
from urllib.parse import quote_plus

if sys.version_info >= (3, 11):
    import tomllib
else:
    import tomli as tomllib

import requests
from rich.text import Text

if TYPE_CHECKING:
    # Typecheck the dashboard event payloads against the versioned,
    # dependency-free winter-plugin-api contract — the narrow seam a plugin codes
    # against. winter-cli is never imported at typecheck time, so the plugin
    # typechecks standalone (see winter-harness:/architecture/plugin-author.md).
    from winter_plugin_api import (
        ActionInvocation,
        ActionScope,
        FeatureWorktreeContext,
        IWinterPlugin,
        IWorktreeRepoStatusView,
        PluginRegistration,
        TuiAction,
    )
else:
    # At runtime winter loads this plugin.py into its own process and supplies
    # the seam from winter_cli; winter_plugin_api is a dev/typecheck-only
    # dependency and is NOT importable here.
    from winter_cli.plugins.types import ActionScope, PluginRegistration, TuiAction

logger = logging.getLogger(__name__)

WINTER_CONFIG_DIR = Path.home() / ".config" / "winter"
USER_CONFIG_PATH = WINTER_CONFIG_DIR / "config.toml"
USER_LOCAL_CONFIG_PATH = WINTER_CONFIG_DIR / "config.local.toml"


def _deep_merge(base: dict, override: dict) -> dict:
    """Recursively merge `override` into `base`; override wins on conflicts.

    Nested tables are merged key-by-key; scalars and lists are replaced
    wholesale by the override value.
    """
    merged = dict(base)
    for key, value in override.items():
        existing = merged.get(key)
        if isinstance(existing, dict) and isinstance(value, dict):
            merged[key] = _deep_merge(existing, value)
        else:
            merged[key] = value
    return merged


def load_user_config() -> dict:
    """Load `~/.config/winter/config.toml`, with `config.local.toml` overlaid on top.

    Either file may be absent. `config.local.toml` is gitignored and holds
    machine-local secrets (e.g. the GitLab token); the shared `config.toml`
    can be committed to dotfiles. Local values override shared ones.
    """
    config: dict = {}
    for path in (USER_CONFIG_PATH, USER_LOCAL_CONFIG_PATH):
        if not path.is_file():
            continue
        with path.open("rb") as f:
            config = _deep_merge(config, tomllib.load(f))
    return config


class GitLabClient:

    def __init__(self, url: str, token: str) -> None:
        self._url = url.rstrip("/")
        self._session = requests.Session()
        self._session.headers["PRIVATE-TOKEN"] = token
        self._mr_cache: dict[str, list[dict]] = {}

    def get_open_mrs(self, project_path: str, source_branch: str) -> list[dict]:
        cache_key = f"{project_path}:{source_branch}"
        if cache_key in self._mr_cache:
            return self._mr_cache[cache_key]

        encoded = quote_plus(project_path)
        url = f"{self._url}/api/v4/projects/{encoded}/merge_requests"
        try:
            resp = self._session.get(url, params={
                "source_branch": source_branch,
                "state": "opened",
                "per_page": 5,
            }, timeout=10)
            resp.raise_for_status()
            mrs = resp.json()
        except Exception:
            logger.debug("GitLab API call failed for %s", project_path, exc_info=True)
            mrs = []

        for mr in mrs:
            mr["_approved"] = self._check_approved(encoded, mr["iid"])

        self._mr_cache[cache_key] = mrs
        return mrs

    def _check_approved(self, encoded_project: str, mr_iid: int) -> bool:
        url = f"{self._url}/api/v4/projects/{encoded_project}/merge_requests/{mr_iid}/approvals"
        try:
            resp = self._session.get(url, timeout=10)
            resp.raise_for_status()
            return resp.json().get("approved", False)
        except Exception:
            return False


def _parse_remote_url(remote_url: str) -> tuple[str, str] | None:
    match = re.match(r"git@([^:]+):(.+?)\.git$", remote_url)
    if match:
        return f"https://{match.group(1)}", match.group(2)
    match = re.match(r"(https?://[^/]+)/(.+?)(?:\.git)?$", remote_url)
    if match:
        return match.group(1), match.group(2)
    return None


def _format_mr_badge(mr: dict) -> Text:
    iid = mr.get("iid", "?")
    text = Text()
    text.append(f"!{iid}", style="#e24329")

    if mr.get("_approved"):
        text.append(" ✔", style="green")
    else:
        text.append(" ○", style="dim")

    pipeline = mr.get("head_pipeline")
    if pipeline:
        status = pipeline.get("status", "")
        icon_map = {"success": ("✓", "green"), "failed": ("✗", "red"), "running": ("⟳", "yellow"), "pending": ("…", "dim")}
        entry = icon_map.get(status)
        if entry:
            text.append(f" {entry[0]}", style=entry[1])

    return text


class GitLabDecorator:

    def __init__(self, token: str) -> None:
        self._token = token
        self._clients: dict[str, GitLabClient] = {}
        self._repo_remotes: dict[tuple[str, Path], tuple[str, str] | None] = {}
        self._url_cache: dict[Path, str | None] = {}

    def get_cached_url(self, worktree_path: Path) -> str | None:
        return self._url_cache.get(worktree_path)

    def __call__(self, repo_status: IWorktreeRepoStatusView, repo_path: Path) -> None:
        repo_name = repo_status.worktree.repository.name
        cache_key = (repo_name, repo_path)

        if cache_key not in self._repo_remotes:
            self._repo_remotes[cache_key] = self._resolve_remote(repo_path)

        remote = self._repo_remotes[cache_key]
        if remote is None:
            self._url_cache[repo_path] = None
            return

        base_url, project_path = remote
        client = self._get_client(base_url)

        tracking = self._tracking_branch(repo_path)
        if tracking is None:
            self._url_cache[repo_path] = None
            return
        feature_branch = tracking.removeprefix("origin/")

        mrs = client.get_open_mrs(project_path, feature_branch)
        if mrs:
            web_url = mrs[0].get("web_url")
            repo_status.extensions["gitlab"] = _format_mr_badge(mrs[0])
            repo_status.extensions["_gitlab_url"] = web_url
            self._url_cache[repo_path] = web_url
        else:
            self._url_cache[repo_path] = None

    def _get_client(self, base_url: str) -> GitLabClient:
        if base_url not in self._clients:
            self._clients[base_url] = GitLabClient(base_url, self._token)
        return self._clients[base_url]

    @staticmethod
    def _resolve_remote(repo_path: Path) -> tuple[str, str] | None:
        try:
            import git
            r = git.Repo(str(repo_path))
            return _parse_remote_url(r.remotes.origin.url)
        except Exception:
            return None

    @staticmethod
    def _tracking_branch(repo_path: Path) -> str | None:
        """The worktree's upstream tracking branch (e.g. 'origin/feature/x'), or None.

        winter's concrete WorktreeRepoStatus exposes this as `.tracking_branch`,
        but that field is off the narrow winter-plugin-api contract
        (`IWorktreeRepoStatusView` is the event surface a decorator may read), so
        we resolve it from git directly — the same upstream (`@{u}`) winter reads.
        """
        try:
            import git
            r = git.Repo(str(repo_path))
            tb = r.active_branch.tracking_branch()
            return tb.name if tb is not None else None
        except Exception:
            return None


class GitLabPlugin:
    name = "gitlab"

    def register(self, config: object) -> PluginRegistration:
        token = self._load_token()
        if not token:
            logger.debug(
                "GitLab plugin: no token in %s or %s, skipping",
                USER_CONFIG_PATH,
                USER_LOCAL_CONFIG_PATH,
            )
            return PluginRegistration()

        decorator = GitLabDecorator(token)

        def _open_mr(ctx: FeatureWorktreeContext | ActionInvocation) -> None:
            url = decorator.get_cached_url(ctx.worktree.path)
            if not url:
                logger.debug("GitLab plugin: no cached MR URL for %s", ctx.worktree.path)
                return
            webbrowser.open(url)

        return PluginRegistration(
            worktree_repo_decorators=[decorator],
            tui_actions=[
                TuiAction(
                    name="open-mr",
                    scope=ActionScope.feature_worktree,
                    key="m",
                    description="Open MR",
                    handler=_open_mr,
                ),
            ],
        )

    @staticmethod
    def _load_token() -> str | None:
        return load_user_config().get("gitlab", {}).get("token")


def create_plugin() -> IWinterPlugin:
    return GitLabPlugin()
