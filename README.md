# Actions

Composite GitHub Actions for TerraFirmaGreg-Team.

| Dir | Scope |
|---|---|
| `mod/` | Gradle mod pipeline: `info`, `build`, `release` |
| `modpack/` | pakku modpack pipeline: `info`, `pakku-diff`, `build`, `release`, `test`, `export` |
| `pull-request/` | `create`, `automerge` |
| `crowdin/` | `sync`, `postprocess` |
| `discord/` | webhook send |

Usage: `uses: TerraFirmaGreg-Team/Actions/<dir>/<name>@main` (`@1` / `@1.x.y` after release).

Secrets/vars must be passed via inputs.
