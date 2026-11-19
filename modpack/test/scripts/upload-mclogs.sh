#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/lib/report.sh"
need_comment || exit 0

upload() { # $1=file $2=env name
  local url
  url=$(tail -24000 "$1" | curl -fsS --max-time 30 -X POST https://api.mclo.gs/1/log \
    --data-urlencode content@- 2>/dev/null | jq -r '.url // empty' 2>/dev/null || true)
  if [ -n "$url" ]; then
    echo "$2=$url" >> "$GITHUB_ENV"
    echo "$2 -> $url"
  else
    echo "::warning::mclo.gs upload failed: $1"
  fi
  return 0
}

for dir in client server; do
  [ -d "$dir/logs" ] || continue
  [ -s "$dir/logs/latest.log" ]         && upload "$dir/logs/latest.log"         "MCLOGS_${dir^^}_LATEST"         || true
  [ -s "$dir/logs/kubejs/server.log" ]  && upload "$dir/logs/kubejs/server.log"  "MCLOGS_${dir^^}_KUBEJS"         || true
  [ -s "$dir/logs/kubejs/startup.log" ] && upload "$dir/logs/kubejs/startup.log" "MCLOGS_${dir^^}_KUBEJS_STARTUP" || true
  [ -s "$dir/logs/kubejs/client.log" ]  && upload "$dir/logs/kubejs/client.log"  "MCLOGS_${dir^^}_KUBEJS_CLIENT"  || true
  [ -s "$dir/logs/stderr_stream.log" ]  && upload "$dir/logs/stderr_stream.log"  "MCLOGS_${dir^^}_STDERR"         || true
  crash=$(ls -t $dir/crash-reports/*.txt 2>/dev/null | head -1 || true)
  if [ -n "$crash" ] && [ -s "$crash" ]; then
    upload "$crash" "MCLOGS_${dir^^}_CRASH" || true
  fi
  for f in $dir/hs_err_pid*.log; do
    [ -s "$f" ] && upload "$f" "MCLOGS_${dir^^}_HSERR" || true
  done
done
