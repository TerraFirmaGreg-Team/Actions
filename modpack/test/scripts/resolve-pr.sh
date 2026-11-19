#!/usr/bin/env bash
set -euo pipefail

n="${PR_INPUT:-}"
if [ -z "$n" ]; then
  # push / workflow_dispatch: find the open PR whose head is this sha
  n=$(gh api "repos/$REPO/commits/$SHA/pulls" \
        --jq '[.[] | select(.state == "open")][0].number // empty' 2>/dev/null || true)
fi

if [ -n "$n" ]; then
  echo "PR_NUMBER=$n" >> "$GITHUB_ENV"
else
  echo "::warning::no open PR for $SHA — PR comment skipped"
fi
