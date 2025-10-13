# 📦 Build Modpack Artifacts

Composite action, подготавливающее артефакты модпака: CurseForge, Modrinth, serverpack и MultiMC. Внутри используется `pakku export`, переименовываются файлы и загружаются через `actions/upload-artifact`.

## Использование
```yaml
steps:
  - uses: TerraFirmaGreg-Team/Actions/build@v1
    id: build
    with:
      project_name: ${{ needs.info.outputs.project_name }}
      project_version: ${{ needs.info.outputs.project_version }}
      project_full_name: ${{ needs.info.outputs.project_full_name }}
```

## Inputs
- `project_name` *(required)*
- `project_version` *(required)*
- `project_full_name` *(required)*
- `release_type` (default `release`)
- `apply_version_overrides` (default `true`)
- `artifact_curseforge` (default `true`)
- `artifact_modrinth` (default `true`)
- `artifact_server` (default `true`)
- `artifact_multimc` (default `true`)
- `pakku_arguments` (default `""`)

## Outputs
- `curseforge_name`
- `modrinth_name`
- `server_name`
- `multimc_name`

## Подключение артефактов в следующих job
```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: TerraFirmaGreg-Team/Actions/build@v1
        id: build
        with: {...}
      - run: echo "Server: ${{ steps.build.outputs.server_name }}"
```
