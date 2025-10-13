# 🖥️ Collect Modpack Info

Composite action для подготовки метаданных релиза TerraFirmaGreg. Парсит `pakku.json`, `pakku-lock.json` и changelog, строит diff и определяет, нужны ли релиз и PR.

## Использование
```yaml
jobs:
  info:
    runs-on: ubuntu-latest
    steps:
      - uses: TerraFirmaGreg-Team/Actions/info@v1
        id: collect
        with:
          stable_branch: main
          dev_branch: dev
```

## Inputs
- `stable_branch` (default `main`)
- `dev_branch` (default `dev`)
- `enable_dev_mode` (default `true`)
- `changelog_path` (default `CHANGELOG.md`)
- `changelog_unreleased_label` (default `unreleased`)
- `pakku_diff_enabled` (default `true`)

## Outputs
- `project_name`
- `project_version`
- `project_full_name`
- `release_type`
- `mc_version`
- `loader_type`
- `loader_version`
- `changelog`
- `diff`
- `tag_exists`
- `make_release`
- `make_pr`

## Проброс результатов
```yaml
jobs:
  info:
    runs-on: ubuntu-latest
    outputs:
      project_name: ${{ steps.collect.outputs.project_name }}
      project_version: ${{ steps.collect.outputs.project_version }}
      project_full_name: ${{ steps.collect.outputs.project_full_name }}
      release_type: ${{ steps.collect.outputs.release_type }}
      mc_version: ${{ steps.collect.outputs.mc_version }}
      changelog: ${{ steps.collect.outputs.changelog }}
      diff: ${{ steps.collect.outputs.diff }}
      make_release: ${{ steps.collect.outputs.make_release }}
      make_pr: ${{ steps.collect.outputs.make_pr }}
    steps:
      - uses: TerraFirmaGreg-Team/Actions/info@v1
        id: collect
```
