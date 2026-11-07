# Shared report helpers for modpack/test.
# Sourced by the "Test summary" and "Build failure report" run blocks.
# NOTE: ${{ }} expressions do NOT interpolate here — everything via env vars.

ERR_RE='InjectionError|Mixin apply failed|Caused by:|(/|\[)(ERROR|FATAL)'
# Ubiquitous forge/mod noise that lands at ERROR level but kills nothing.
BENIGN_RE='does not specify "minVersion"|Failed to load.*access.?[Tt]ransformer|Skipping bad option|suppressed'

need_comment() { # report needed: any side failed / server never ran / findings exist
  [ "${CLIENT_RESULT:-}" = "fail" ] && return 0
  [ "${SERVER_RESULT:-}" = "fail" ] && return 0
  [ "${ANALYZE_BAD:-}" = "1" ] && return 0
  { [ "${HAS_SERVER:-}" = "true" ] && [ "${SERVER_RESULT:-}" = "skipped" ]; }
}

report_title() {
  if [ "${CLIENT_RESULT:-}" = "fail" ] || [ "${SERVER_RESULT:-}" = "fail" ] \
    || { [ "${HAS_SERVER:-}" = "true" ] && [ "${SERVER_RESULT:-}" = "skipped" ]; }; then
    echo '### Runtime test failed'
  else
    echo '### Runtime test — log findings'
  fi
}

side_status() { local v="${1^^}_RESULT"; eval "echo \${$v:-n/a}"; }

logs_md() {
  local out="" u
  u=${MCLOGS_CLIENT_LATEST:-$CLIENT_LOGS_URL}
  [ -n "$u" ] && out="[client]($u)"
  u=${MCLOGS_SERVER_LATEST:-$SERVER_LOGS_URL}
  [ -n "$u" ] && out+="${out:+ · }[server]($u)"
  [ -n "$out" ] && echo "**Logs**: $out"
  return 0
}

spark_md() { # "**Spark flame graphs**: [client](u) · [server](u)" when viewer links exist
  local out="" c=${SPARK_CLIENT_LINK:-} s=${SPARK_SERVER_LINK:-}
  [ -n "$c" ] && out="[client]($c)"
  [ -n "$s" ] && out+="${out:+ · }[server]($s)"
  [ -n "$out" ] && echo "**Spark flame graphs**: $out"
  return 0
}

error_chunks() { # $1=file $2=max → first cluster + '…' + last clusters, benign-filtered
  local out first rest n budget
  out=$(grep -n -C12 -E "$ERR_RE" "$1" | grep -vE "$BENIGN_RE" || true)
  [ -z "$out" ] && { tail -"$2" "$1"; return 0; }
  n=$(printf '%s\n' "$out" | grep -c '')
  if [ "$n" -le "$2" ]; then printf '%s\n' "$out"; return 0; fi
  first=$(printf '%s\n' "$out" | awk '/^--$/{exit} {print}')
  rest=$(printf '%s\n' "$out" | awk 'f{print} /^--$/{f=1}')
  budget=$(( $2 - $(printf '%s\n' "$first" | grep -c '') - 4 ))
  [ "$budget" -lt 1 ] && budget=1
  printf '%s\n…\n' "$first"
  printf '%s\n' "$rest" | tail -n "$budget"
}

log_excerpt() { # $1=file $2=max $3=[head] → prints "LABEL" line then excerpt lines
  local a
  a=$(grep -nF -- '---- Minecraft Crash Report ----' "$1" | tail -1 | cut -d: -f1 || true)
  if [ -n "$a" ]; then
    echo 'crash report'
    tail -n "+$a" "$1" \
      | sed '/Mod List:/,/Crash Report UUID/{/Crash Report UUID/!d}' \
      | head -"$2"
    return 0
  fi
  if grep -qE "$ERR_RE" "$1"; then
    echo 'error context'
    error_chunks "$1" "$2"
    return 0
  fi
  if [ "$3" = "head" ]; then echo "head $2"; head -"$2" "$1"; else echo "tail $2"; tail -"$2" "$1"; fi
}

spark_stats() { # $1=latest.log → spark metrics only (TPS/CPU/mem)
  local a
  a=$(grep -nF 'Generating server health report' "$1" 2>/dev/null | tail -1 | cut -d: -f1 || true)
  [ -z "$a" ] && return 0
  tail -n "+$a" "$1" | grep -E '\[spark[/:\]]' \
    | sed -E 's/^\[[0-9:.]+\] (\[[^]]*\] ?)+: //' \
    | grep -E '^(Generating server health|>|[[:space:]]+[0-9])' \
    | head -30
}

file_details() { # $1=dir $2=relpath $3=name $4=mclo env suffix $5=max $6=[errors_only|head]
  [ -s "$1/$2" ] || return 0
  case "$6" in
    errors_only) grep -qE "$ERR_RE" "$1/$2" || return 0 ;;
  esac
  local out body label link="" var
  out=$(log_excerpt "$1/$2" "$5" "$6")
  label=${out%%$'\n'*}
  body=${out#*$'\n'}
  var="MCLOGS_${1^^}_$4"
  [ -n "$4" ] && eval "link=\${$var:-}"
  echo "<details><summary>$3 — $label${link:+ · <a href=\"$link\">full log</a>}</summary>"
  echo ''
  echo '```text'
  echo "$body"
  echo '```'
  echo ''
  echo '</details>'
  echo ''
}

group_details() { # $1=title; stdin → wrapped in named <details> only when non-empty
  local inner
  inner=$(cat)
  [ -z "${inner//[[:space:]]/}" ] && return 0
  echo "<details><summary><b>$1</b></summary>"
  echo ''
  echo "$inner"
  echo '</details>'
  echo ''
}

side_details() { # $1=dir $2=artifact url
  local inner
  inner=$(
    {
      file_details "$1" logs/latest.log latest.log LATEST 140
    } | group_details "logs"
    {
      file_details "$1" logs/kubejs/server.log kubejs/server.log KUBEJS 100 errors_only
      file_details "$1" logs/kubejs/startup.log kubejs/startup.log KUBEJS_STARTUP 100 errors_only
      file_details "$1" logs/kubejs/client.log kubejs/client.log KUBEJS_CLIENT 100 errors_only
    } | group_details "kubejs-logs"
    {
      crash=$(ls -t $1/crash-reports/*.txt 2>/dev/null | head -1 || true)
      [ -n "$crash" ] && [ -s "$crash" ] && file_details "$1" "${crash#$1/}" "$(basename "$crash")" CRASH 140
      for f in $1/hs_err_pid*.log; do
        [ -s "$f" ] && file_details "$1" "${f#$1/}" "$(basename "$f")" HSERR 80 head
      done
    } | group_details "crash-logs"
    {
      file_details "$1" logs/stderr_stream.log stderr_stream.log STDERR 100 errors_only
      file_details "$1" logs/crash_assistant/crash_assistant_app.log crash_assistant.log "" 60 errors_only
    } | group_details "other"
    {
      block=$(spark_stats "$1/logs/latest.log" 2>/dev/null || true)
      eval "link=\${SPARK_${1^^}_LINK:-}"
      if [ -n "$block" ]; then
        echo '```text'
        echo "$block"
        echo '```'
        echo ''
      fi
      [ -n "$link" ] && echo "[Interactive flame graph]($link)"
    } | group_details "spark stats"
  ) || true
  [ -z "${inner//[[:space:]]/}" ] && return 0
  echo "<details><summary><b>$1 — $(side_status "$1")</b>${2:+ · <a href=\"$2\">download $1 logs</a>}</summary>"
  echo ''
  echo "$inner"
  echo '</details>'
  echo ''
}
