# Actions
# Composite actions for TerraFirmaGreg

## Обзор
Пакет готовых **composite actions** для автоматизации жизненного цикла модпака `TerraFirmaGreg`. Набор покрывает сборку, публикацию, создание PR и уведомления. Действия вызываются напрямую внутри job, обеспечивая единообразие между репозиториями модпаков.

## Структура
- `info/` — подготовка метаданных релиза (версия, changelog, diff).
- `build/` — сборка артефактов (CurseForge, Modrinth, Serverpack, MultiMC).
- `release/` — публикация на GitHub/CurseForge/Modrinth, закрытие задач.
- `create-pr/` — создание релизного PR.
- `message/` — отправка уведомления в Discord.
- `tests/` — фикстуры для smoke-тестов.
- `.github/workflows/ci.yml` — линтинг и smoke-тесты.
- `.github/workflows/release.yml` — автогенерация релизов.

## Сводка действий
| Action | Назначение | Основные входы | Ключевые выходы |
| --- | --- | --- | --- |
| `info` | Подготовка метаданных, changelog, diff | `stable_branch`, `dev_branch`, `pakku_diff_enabled` | `project_*`, `changelog`, `diff`, `make_release`, `make_pr` |
| `build` | Экспорт и упаковка артефактов | `project_*`, флаги `artifact_*` | `curseforge_name`, `modrinth_name`, `server_name`, `multimc_name` |
| `release` | Публикация релиза и закрытие задач | `project_full_name`, `project_version`, `enable_release_*` | `github_release_url`, `curseforge_file_id`, `modrinth_release_id` |
| `create-pr` | Создание релизного PR | `project_*`, `changelog` | `pr_number`, `pr_url` |
| `message` | Discord уведомление | `webhook_secret`, `content` | – |

## Базовое использование
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
      - name: 🖥️ Collect info
        id: collect
        uses: TerraFirmaGreg-Team/Actions/info@1.0.0
        with:
          stable_branch: main
          dev_branch: dev

  build:
    needs: info
    runs-on: ubuntu-latest
    steps:
      - uses: TerraFirmaGreg-Team/Actions/build@1.0.0
        with:
          project_name: ${{ needs.info.outputs.project_name }}
          project_version: ${{ needs.info.outputs.project_version }}
          project_full_name: ${{ needs.info.outputs.project_full_name }}

  release:
    needs: [info, build]
    if: needs.info.outputs.make_release == 'true'
    runs-on: ubuntu-latest
    steps:
      - uses: TerraFirmaGreg-Team/Actions/release@1.0.0
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

  message:
    needs: [info, release]
    if: needs.info.outputs.make_release == 'true'
    runs-on: ubuntu-latest
    steps:
      - uses: TerraFirmaGreg-Team/Actions/message@1.0.0
        with:
          webhook_secret: DISCORD_RELEASES
          content: |
            **Release**: `${{ needs.info.outputs.project_version }}`
            **Game Version**: `${{ needs.info.outputs.mc_version }}`
          mention_role_id: ${{ vars.DISCORD_ROLE_RELEASE }}
```

## Релизы
- Workflow `release.yml` автоматически создаёт GitHub Release при изменениях в директориях action-ов и документации.
- Версионирование — семантическое, теги формата `1.0.0`.
- Для ручного тега:
  ```bash
  git tag 1.0.0
  git push origin 1.0.0
  ```
- Для ручного запуска релизного workflow используйте `workflow_dispatch` с ветки `main`.
- После релиза обновите внешние репозитории:
  - `info` → `TerraFirmaGreg-Team/Actions/info@1.0.0`
  - `build` → `TerraFirmaGreg-Team/Actions/build@1.0.0`
  - `release` → `TerraFirmaGreg-Team/Actions/release@1.0.0`
  - `create-pr` → `TerraFirmaGreg-Team/Actions/create-pr@1.0.0`
  - `message` → `TerraFirmaGreg-Team/Actions/message@1.0.0`

## Документация по действиям
Подробности (включая примеры и таблицы входов/выходов) находятся в файлах:
- `info/README.md`
- `build/README.md`
- `release/README.md`
- `create-pr/README.md`
- `message/README.md`
