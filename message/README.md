# 📣 Send Discord Notification

Composite action для отправки уведомления о релизе в Discord. Поддерживает обрезку длинного текста и упоминание роли.

## Использование
```yaml
steps:
  - uses: TerraFirmaGreg-Team/Actions/message@v1
    with:
      enabled: ${{ needs.info.outputs.make_release == 'true' }}
      webhook_secret: DISCORD_RELEASES
      content: |
        **Release**: `${{ needs.info.outputs.project_version }}`
        **Game Version**: `${{ needs.info.outputs.mc_version }}`
      mention_role_id: ${{ vars.DISCORD_ROLE_RELEASE }}
```

## Inputs
- `enabled` (default `true`)
- `webhook_secret` *(required)*
- `username` (default `TerraFirmaGreg`)
- `avatar_url` (default логотип)
- `content` *(required)*
- `embed_title` (default `""`)
- `embed_description` (default `""`)
- `mention_role_id` (default `""`)
- `truncate_length` (default `0`)

## Secrets
- `secrets[inputs.webhook_secret]`

## Пример с обрезкой changelog
```yaml
steps:
  - uses: TerraFirmaGreg-Team/Actions/message@v1
    with:
      webhook_secret: DISCORD_RELEASES
      content: ${{ needs.info.outputs.changelog }}
      truncate_length: 1450
```
