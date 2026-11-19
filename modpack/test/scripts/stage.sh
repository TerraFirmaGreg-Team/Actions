#!/usr/bin/env bash
set -euo pipefail

SHARED="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../scripts" && pwd)"

case "$1" in
  client)
    mkdir -p client-unzip client
    unzip -oq pack-client/*.zip -d client-unzip
    cp -rf client-unzip/.minecraft/. client/
    bash "$SHARED/disable-ftbbackups.sh" client
    # Forge 47 early window spams a y/n prompt under headless CI.
    mkdir -p client/config
    if grep -q 'earlyWindowControl' client/config/fml.toml 2>/dev/null; then
      sed -i 's/^ *earlyWindowControl *= *.*/earlyWindowControl = false/' client/config/fml.toml
    else
      echo 'earlyWindowControl = false' >> client/config/fml.toml
    fi
    ;;
  server)
    mkdir -p server
    unzip -oq pack-server/*.zip -d server
    bash "$SHARED/disable-ftbbackups.sh" server
    ;;
  *) echo "::error::unknown side '$1'" >&2; exit 1 ;;
esac
