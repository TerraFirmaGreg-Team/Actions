# mod/

Gradle mod pipeline (Core-Modern, Core-Vintage, Mod-Template).

| Action | What it does |
|---|---|
| `info` | `gradle.properties` metadata + tag check → `version`, `full_name`, `make_release` |
| `build` | optional version replace, setup-java, gradle tasks, jar artifact |
| `release` | publish via `Xikaro/game-publish@main` |
