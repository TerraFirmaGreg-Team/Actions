#!/usr/bin/env bash
set -euo pipefail

logs_cell() {
  local o=""
  [ -n "${CLIENT_LOGS_URL:-}" ] && o="[client]($CLIENT_LOGS_URL)"
  [ -n "${SERVER_LOGS_URL:-}" ] && o+="${o:+ · }[server]($SERVER_LOGS_URL)"
  echo "${o:-n/a}"
}

{
  echo "### Runtime test"
  echo ""
  echo "| Check | Result |"
  echo "|---|---|"
  echo "| Client | ${CLIENT_RESULT:-n/a} |"
  echo "| Server | ${SERVER_RESULT:-n/a} |"
  echo "| Logs | $(logs_cell) |"
} >> "$GITHUB_STEP_SUMMARY"
