#!/usr/bin/env bash
set -euo pipefail

# Findings only — pass/fail comes from the test step outcomes.
bad=0
: > analysis.md

for dir in client server; do
  [ -d "$dir/logs" ] || continue

  kerr=$(grep -rsh 'ERROR' $dir/logs/kubejs/*.log 2>/dev/null; grep -h "Error in '" $dir/logs/latest.log 2>/dev/null | head -3 || true)
  if [ -n "$kerr" ]; then
    echo "::warning title=KubeJS errors ($dir)::$(echo "$kerr" | head -5 | tr '\n' ' ')"
    {
      echo "**KubeJS errors ($dir)**:"
      echo '```text'
      echo "$kerr" | head -5
      echo '```'
    } >> analysis.md
    bad=1
  fi

  if grep -sqE 'Mixin apply failed|InjectionError' $dir/logs/latest.log; then
    echo "::warning title=Mixin failure ($dir)::$(grep -m3 -E 'Mixin apply failed|InjectionError' $dir/logs/latest.log | tr '\n' ' ')"
    {
      echo "**Mixin failure ($dir)**:"
      echo '```text'
      grep -m3 -E 'Mixin apply failed|InjectionError' $dir/logs/latest.log
      echo '```'
    } >> analysis.md
    bad=1
  fi

  rec=$(grep -c 'Parsing error loading recipe' $dir/logs/latest.log 2>/dev/null || true)
  if [ "${rec:-0}" -gt 0 ]; then
    echo "::warning title=Recipe parse errors ($dir)::$rec in latest.log"
    echo "- **Recipe parse errors ($dir)**: $rec in latest.log" >> analysis.md
  fi

  dp=$(grep -cE "Couldn't load data tag|Couldn't parse data file" $dir/logs/latest.log 2>/dev/null || true)
  if [ "${dp:-0}" -gt 0 ]; then
    echo "::warning title=Datapack issues ($dir)::$dp in latest.log"
    echo "- **Datapack issues ($dir)**: $dp in latest.log" >> analysis.md
  fi
done

[ "$bad" = 1 ] && echo "ANALYZE_BAD=1" >> "$GITHUB_ENV" || true
