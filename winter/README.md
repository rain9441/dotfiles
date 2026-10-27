# winter config

Synced config + plugins for the winter workspace CLI. `~/.config/winter` is symlinked here by `mac.sh` / `linux.sh`.

Machine-local overrides/secrets go in `config.local.toml` (gitignored), next to the shared `config.toml`.

## Dashboard plugins

`plugins/nvim` is a winter TUI dashboard plugin (open in Neovim, CodeDiff, …). winter loads each `plugin.py` into its
own process and supplies the plugin seam from winter-cli at runtime.

Its dashboard event payloads — decorator `__call__`s and keybound action handlers — are type-checked against the
versioned, dependency-free [`winter-plugin-api`](https://github.com/paul-gross/winter-plugin-api) contract. The contract
is imported only under `TYPE_CHECKING` (winter-cli is never imported at typecheck time, and `winter_plugin_api` is never
imported at runtime), so the plugin typechecks standalone:

```bash
cd plugins && uv run pyright
```

`plugins/pyproject.toml` is a typecheck-only project: its sole dependency is `winter-plugin-api` (pinned to a tag). The
plugins' runtime third-party libs (`requests`, `rich`, GitPython) come from winter's process, so pyright reports them as
warnings here, not errors.
