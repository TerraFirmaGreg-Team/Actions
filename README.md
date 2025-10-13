# Actions
# Composite actions for TerraFirmaGreg repos

## Общая информация
Репозиторий содержит набор **composite actions** для сборки и релизов модпака `TerraFirmaGreg`. Каждое действие подключается на уровне шага (`uses`) внутри job целевого workflow.

```yaml
jobs:
  job-id:
    runs-on: ubuntu-latest
    steps:
      - name: Run action
        id: step-id
        uses: TerraFirmaGreg-Team/Actions/<action>@v1
        with:
          # входные параметры
        env:
          # дополнительные переменные, если нужны
```

### `info`
- **Назначение**: Сбор метаданных модпака, подготовка changelog, diff, определение необходимости релиза и PR.
- **Входы**: `stable_branch`, `dev_branch`, `changelog_path`, `changelog_unreleased_label`, `pakku_diff_enabled`.
- **Выходы**: `project_*`, `release_type`, `mc_version`, `loader_*`, `changelog`, `diff`, `tag_exists`, `make_release`, `make_pr`.
- **Пример**:
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
        - name: Collect info
          id: collect
          uses: TerraFirmaGreg-Team/Actions/info@v1
          with:
            stable_branch: main
            dev_branch: dev
  ```

### `create-pr`
- **Назначение**: Создание релизного PR.
- **Входы**: `enabled`, `source_branch`, `target_branch`, `project_*`, `changelog`, шаблоны заголовка/тела.
- **Выходы**: `pr_number`, `pr_url`. **Секреты**: `GITHUB_TOKEN`.
- **Пример**:
  ```yaml
  jobs:
    create_pr:
      needs: info
      if: needs.info.outputs.make_pr == 'true'
      runs-on: ubuntu-latest
      steps:
        - uses: TerraFirmaGreg-Team/Actions/create-pr@v1
          with:
            project_name: ${{ needs.info.outputs.project_name }}
            project_version: ${{ needs.info.outputs.project_version }}
            project_full_name: ${{ needs.info.outputs.project_full_name }}
            changelog: ${{ needs.info.outputs.changelog }}
          env:
            GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  ```

### `build`
- **Назначение**: Экспорт артефактов (CurseForge, Modrinth, serverpack, MultiMC).
- **Входы**: `project_*`, `release_type`, флаги `artifact_*`, `apply_version_overrides`, `pakku_arguments`.
- **Выходы**: `curseforge_name`, `modrinth_name`, `server_name`, `multimc_name`.
- **Пример**:
  ```yaml
  jobs:
    build:
      needs: info
      runs-on: ubuntu-latest
      steps:
        - uses: TerraFirmaGreg-Team/Actions/build@v1
          with:
            project_name: ${{ needs.info.outputs.project_name }}
            project_version: ${{ needs.info.outputs.project_version }}
            project_full_name: ${{ needs.info.outputs.project_full_name }}
  ```

### `release`
- **Назначение**: Публикация релиза на GitHub, CurseForge, Modrinth, закрытие задач.
- **Входы**: `enabled`, `project_full_name`, `project_version`, `release_type`, `changelog`, `diff`, `mc_version`, флаги публикаций и дополнительные параметры.
- **Выходы**: `github_release_url`, `curseforge_file_id`, `modrinth_release_id`.
- **Секреты / Vars**: `GITHUB_TOKEN`, `CURSEFORGE_TOKEN`, `vars.CURSEFORGE_ID`, `MODRINTH_TOKEN`.
- **Пример**:
  ```yaml
  jobs:
    release:
      needs: [info, build]
      if: needs.info.outputs.make_release == 'true'
      runs-on: ubuntu-latest
      steps:
        - uses: TerraFirmaGreg-Team/Actions/release@v1
          with:
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

### `message`
- **Назначение**: Отправка уведомления в Discord.
- **Входы**: `enabled`, `webhook_secret`, `username`, `avatar_url`, `content`, `embed_title`, `embed_description`, `mention_role_id`, `truncate_length`.
- **Выходы**: отсутствуют. **Секреты**: `secrets[inputs.webhook_secret]`.
- **Пример**:
  ```yaml
  jobs:
    message:
      needs: [info, release]
      if: needs.info.outputs.make_release == 'true'
      runs-on: ubuntu-latest
      steps:
        - uses: TerraFirmaGreg-Team/Actions/message@v1
          with:
            webhook_secret: DISCORD_RELEASES
            content: |
              **Release**: `${{ needs.info.outputs.project_version }}`
              **Game Version**: `${{ needs.info.outputs.mc_version }}`
            mention_role_id: ${{ vars.DISCORD_ROLE_RELEASE }}
  ```
