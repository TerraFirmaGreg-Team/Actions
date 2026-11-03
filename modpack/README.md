# modpack/

Pakku modpack pipeline (Modern, Vintage, Template).

| Action | What it does |
|---|---|
| `info` | pakku metadata + changelog + tag check → `make_release`, `make_pr` |
| `route` | job-routing flags (`test`/`export`/`changelog`/`message`) from needs results + dispatch inputs |
| `pakku-diff` | pakku-lock diff vs latest stable tag |
| `build` | placeholders + `pakku export` + artifacts (cf/mr/multimc/serverpack/docker) |
| `release` | publish via `Xikaro/game-publish@main` |
| `test` | HeadlessMC client (multimc pack) + server (serverpack, pinned loader) smoke tests; summary, logs, PR comment on failure |
| `export` | Wiki pipeline: run-artifact or released pack (via `version` tag) → game dump → S3 |
| `discord` | release notification to Discord |

`pakku_jar: local` (committed jar) or `download`.


