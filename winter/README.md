# winter config

Synced config + plugins for the winter workspace CLI.
`~/.config/winter` is symlinked here by `mac.sh` / `linux.sh`.

Secrets go in `config.local.toml` (gitignored), which plugins deep-merge on top
of the shared `config.toml` — local values win. Copy `config.local.toml.example`
to `config.local.toml` and fill it in on each machine.
