#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/lib/report.sh"
need_comment || exit 0

TITLE=$(report_title)

{
  echo "$TITLE"
  echo ''
  echo "**Client**: ${CLIENT_RESULT:-n/a} · **Server**: ${SERVER_RESULT:-n/a}"
  logs_md
} > pr-comment-short.md

{
  echo "$TITLE"
  echo ''
  echo "**Client**: ${CLIENT_RESULT:-n/a} · **Server**: ${SERVER_RESULT:-n/a}"
  logs_md
  echo ''
  found=0
  if [ -s analysis.md ]; then
    echo '<details><summary><b>Findings</b></summary>'
    echo ''
    cat analysis.md
    echo ''
    echo '</details>'
    echo ''
    found=1
  fi
  side_details client "$CLIENT_LOGS_URL"
  side_details server "$SERVER_LOGS_URL"
  if [ "$found" -eq 0 ] && ! compgen -G 'client/logs/*' >/dev/null && ! compgen -G 'server/logs/*' >/dev/null; then
    echo 'No logs found — see workflow log.'
  fi
} > pr-comment.md

cat pr-comment.md >> "$GITHUB_STEP_SUMMARY"

# PR comments cap at 65536 chars — fall back to the short form past 60KB.
if [ "$(wc -c < pr-comment.md)" -gt 60000 ]; then
  {
    cat pr-comment-short.md
    echo ''
    echo '_Full details too large — see job summary and artifacts._'
  } > pr-comment.md
fi

echo "COMMENT=1" >> "$GITHUB_ENV"
