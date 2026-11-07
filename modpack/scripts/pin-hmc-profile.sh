# hmc has no --java flag — a saved profile's javaVersion wins over version.json.
# env: LOADER_TYPE, MC_VERSION, JAVA_VERSION; run from the workspace root.
set -euo pipefail
case "$JAVA_VERSION" in ''|*[!0-9]*)
  echo "::error::JAVA_VERSION '$JAVA_VERSION' must be a major version int (e.g. 17)"
  exit 1 ;;
esac
mkdir -p HeadlessMC/profiles
cat <<EOF >> HeadlessMC/config.properties
hmc.java.download=false
hmc.java.versions=$JAVA_HOME/bin/java
EOF
cat <<EOF > "HeadlessMC/profiles/${LOADER_TYPE}-${MC_VERSION}.json"
{
  "name": "${LOADER_TYPE}-${MC_VERSION}",
  "version": {"platform": "${LOADER_TYPE}", "version": "${MC_VERSION}"},
  "currentVersion": {"platform": "${LOADER_TYPE}", "version": "${MC_VERSION}"},
  "path": "$PWD/run",
  "options": {"resolution": null, "quickPlayPath": null, "join": null, "demo": false},
  "patchers": [],
  "systemProperties": {},
  "vmArgs": [],
  "javaVersion": ${JAVA_VERSION},
  "eulaStatus": "UNKNOWN",
  "hasDefaultClientJvmArgs": false,
  "hmcVersion": 0
}
EOF
