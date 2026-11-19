#!/usr/bin/env bash
set -euo pipefail

case "$1" in
  client)
    SHARED="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../scripts" && pwd)"
    ln -sfn client run
    bash "$SHARED/pin-hmc-profile.sh"
    ;;
  server)
    # version.json javaVersion pins the server JVM (hmc has no --java flag);
    # cache-mc must stay 'false' — a restore would clobber the seeded file.
    ln -sfn server run
    VJ="$HOME/.minecraft/versions/$MC_VERSION/$MC_VERSION.json"
    mkdir -p "$(dirname "$VJ")"
    URL="$(curl -fsSL "https://launchermeta.mojang.com/mc/game/version_manifest_v2.json" \
      | jq -r --arg v "$MC_VERSION" '.versions[] | select(.id == $v) | .url')"
    [ -n "$URL" ] || { echo "::error::No $MC_VERSION in Mojang version manifest"; exit 1; }
    curl -fsSL "$URL" | jq --argjson jv "$JAVA_VERSION" '.javaVersion.majorVersion = $jv' > "$VJ"
    jq '.javaVersion' "$VJ"
    ;;
  *) echo "::error::unknown side '$1'" >&2; exit 1 ;;
esac
