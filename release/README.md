# 🚀 Release Modpack

Composite action, публикующее релиз на GitHub, CurseForge и Modrinth, а также закрывающее задачи по лейблу.

## Использование
```yaml
steps:
  - uses: TerraFirmaGreg-Team/Actions/release@v1
    id: release
    with:
      enabled: ${{ needs.info.outputs.make_release == 'true' }}
      project_full_name: ${{ needs.info.outputs.project_full_name }}
      project_version: ${{ needs.info.outputs.project_version }}
      release_type: ${{ needs.info.outputs.release_type }}
      changelog: ${{ needs.info.outputs.changelog }}
      diff: ${{ needs.info.outputs.diff }}
      mc_version: ${{ needs.info.outputs.mc_version }}
    env:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      CURSEFORGE_TOKEN: ${{ secrets.CURSEFORGE_TOKEN }}
      MODRINTH_TOKEN: ${{ secrets.MODRINTH_TOKEN }}
```

## Inputs
- `enabled` (default `true`)
- `project_full_name` *(required)*
- `project_version` *(required)*
- `release_type` (default `release`)
- `changelog` (default `""`)
- `diff` (default `""`)
- `mc_version` (default `unknown`)
- `enable_release_github` (default `true`)
- `enable_release_curseforge` (default `true`)
- `enable_release_modrinth` (default `false`)
- `curseforge_slug` (default `""`)
- `modrinth_project_id` (default `""`)
- `close_issues_label` (default `""`)
- `close_issues_comment` (default `""`)

## Outputs
- `github_release_url`
- `curseforge_file_id`
- `modrinth_release_id`

## Secrets / Vars
- `GITHUB_TOKEN`
- `CURSEFORGE_TOKEN`, `vars.CURSEFORGE_ID`
- `MODRINTH_TOKEN`

## Пример условия
```yaml
jobs:
  release:
    needs: [info, build]
    if: needs.info.outputs.make_release == 'true'
    steps:
      - uses: TerraFirmaGreg-Team/Actions/release@v1
        id: release
        with: {...}
        env: {...}
      - run: echo "GitHub URL: ${{ steps.release.outputs.github_release_url }}"
```
