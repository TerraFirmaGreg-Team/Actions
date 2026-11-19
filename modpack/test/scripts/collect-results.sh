#!/usr/bin/env bash
set -euo pipefail

map() { case "$1" in success) echo pass;; skipped) echo skipped;; *) echo fail;; esac; }

echo "CLIENT_RESULT=$(map "$CLIENT_OUTCOME")" >> "$GITHUB_ENV"
echo "SERVER_RESULT=$(map "$SERVER_OUTCOME")" >> "$GITHUB_ENV"
