# 🤝 Create Release Pull Request

Composite action создаёт релизный PR, используя шаблоны заголовка и тела и проверяя существующие PR между ветками.

## Использование
```yaml
steps:
  - uses: TerraFirmaGreg-Team/Actions/create-pr@v1
    id: create
    with:
      project_name: ${{ needs.info.outputs.project_name }}
      project_version: ${{ needs.info.outputs.project_version }}
      project_full_name: ${{ needs.info.outputs.project_full_name }}
      changelog: ${{ needs.info.outputs.changelog }}
    env:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Inputs
- `enabled` (default `true`)
- `source_branch` (default `dev`)
- `target_branch` (default `main`)
- `project_name` *(required)*
- `project_version` *(required)*
- `project_full_name` *(required)*
- `changelog` (default `""`)
- `pr_title_template` (default `"Release: ${VERSION}"`)
- `pr_body_template` (default markdown с переменными `${NAME}`, `${VERSION}`, `${FULL_NAME}`, `${CHANGELOG}`)

## Outputs
- `pr_number`
- `pr_url`

## Пример условия на существующий PR
```yaml
jobs:
  create_pr:
    needs: info
    if: needs.info.outputs.make_pr == 'true'
    runs-on: ubuntu-latest
    steps:
      - uses: TerraFirmaGreg-Team/Actions/create-pr@v1
        id: create
        with: {...}
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      - run: echo "PR URL: ${{ steps.create.outputs.pr_url }}"
```
