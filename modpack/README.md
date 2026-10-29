# modpack/

Pakku modpack pipeline (Modern, Vintage, Template).

| Action | What it does |
|---|---|
| `info` | pakku metadata + changelog + tag check → `make_release`, `make_pr` |
| `pakku-diff` | pakku-lock diff vs latest stable tag |
| `build` | placeholders + `pakku export` + artifacts (cf/mr/multimc/serverpack/docker) |
| `release` | publish via `Xikaro/game-publish@main` |
| `test` | HeadlessMC client launch on built multimc pack; PR comment on failure |
| `export` | live Game-Exporter dump on built multimc pack |
| `discord` | release notification to Discord |

`pakku_jar: local` (committed jar) or `download`.
