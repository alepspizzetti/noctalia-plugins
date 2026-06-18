#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 <plugin-id> [--force-link]"
  exit 1
fi

PLUGIN_ID="$1"
FORCE_LINK="${2:-}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN_DIR="$REPO_ROOT/$PLUGIN_ID"
MANIFEST_PATH="$PLUGIN_DIR/manifest.json"
README_PATH="$PLUGIN_DIR/README.md"
TARGET_ROOT="${HOME}/.config/noctalia/plugins"
TARGET_LINK="$TARGET_ROOT/$PLUGIN_ID"
PLUGINS_JSON="${HOME}/.config/noctalia/plugins.json"
REPO_URL="https://github.com/alepspizzetti/noctalia-plugins"

require_file() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    echo "ERROR: required file missing: $path"
    exit 1
  fi
}

require_file "$MANIFEST_PATH"
require_file "$README_PATH"

if ! command -v node >/dev/null 2>&1; then
  echo "ERROR: node is required to validate manifest.json"
  exit 1
fi

MANIFEST_JSON="$(node -e "const fs=require('fs'); const p=process.argv[1]; const data=JSON.parse(fs.readFileSync(p,'utf8')); process.stdout.write(JSON.stringify(data));" "$MANIFEST_PATH")"
MANIFEST_ID="$(node -e "const data=JSON.parse(process.argv[1]); process.stdout.write(data.id || '');" "$MANIFEST_JSON")"

if [[ "$MANIFEST_ID" != "$PLUGIN_ID" ]]; then
  echo "ERROR: manifest id '$MANIFEST_ID' does not match directory '$PLUGIN_ID'"
  exit 1
fi

ENTRYPOINTS="$(node -e "const data=JSON.parse(process.argv[1]); process.stdout.write(JSON.stringify(data.entryPoints || {}));" "$MANIFEST_JSON")"
ENTRYPOINT_COUNT="$(node -e "const ep=JSON.parse(process.argv[1]); process.stdout.write(String(Object.keys(ep).length));" "$ENTRYPOINTS")"

if [[ "$ENTRYPOINT_COUNT" -eq 0 ]]; then
  echo "ERROR: manifest has no entryPoints"
  exit 1
fi

while IFS=$'\t' read -r key relpath; do
  [[ -z "$key" ]] && continue
  require_file "$PLUGIN_DIR/$relpath"
done < <(node -e 'const ep=JSON.parse(process.argv[1]); for (const [k,v] of Object.entries(ep)) console.log(`${k}\t${v}`);' "$ENTRYPOINTS")

mkdir -p "$TARGET_ROOT"

if [[ -e "$TARGET_LINK" || -L "$TARGET_LINK" ]]; then
  if [[ "$FORCE_LINK" == "--force-link" ]]; then
    if [[ -L "$TARGET_LINK" ]]; then
      rm "$TARGET_LINK"
    else
      echo "ERROR: target exists and is not a symlink: $TARGET_LINK"
      echo "Refusing to remove a real directory or file from ~/.config/noctalia/plugins."
      exit 1
    fi
  else
    echo "ERROR: target already exists: $TARGET_LINK"
    echo "Use --force-link to replace it."
    exit 1
  fi
fi

ln -s "$PLUGIN_DIR" "$TARGET_LINK"

mkdir -p "$(dirname "$PLUGINS_JSON")"
if [[ ! -f "$PLUGINS_JSON" ]]; then
  printf '{\n    "sources": [],\n    "states": {},\n    "version": 2\n}\n' > "$PLUGINS_JSON"
fi

node -e "
const fs = require('fs');
const path = process.argv[1];
const pluginId = process.argv[2];
const repoUrl = process.argv[3];
const data = JSON.parse(fs.readFileSync(path, 'utf8'));
data.states = data.states || {};
if (!data.states[pluginId]) {
  data.states[pluginId] = { enabled: false, sourceUrl: repoUrl };
} else {
  if (typeof data.states[pluginId] !== 'object' || data.states[pluginId] === null) {
    data.states[pluginId] = { enabled: false, sourceUrl: repoUrl };
  } else {
    if (data.states[pluginId].enabled === undefined) data.states[pluginId].enabled = false;
    if (!data.states[pluginId].sourceUrl) data.states[pluginId].sourceUrl = repoUrl;
  }
}
if (data.version === undefined) data.version = 2;
fs.writeFileSync(path, JSON.stringify(data, null, 4) + '\n');
" "$PLUGINS_JSON" "$PLUGIN_ID" "$REPO_URL"

HAS_IPC_TOGGLE=0
MAIN_FILE="$(node -e "const ep=JSON.parse(process.argv[1]); process.stdout.write(ep.main || '');" "$ENTRYPOINTS")"
if [[ -n "$MAIN_FILE" && -f "$PLUGIN_DIR/$MAIN_FILE" ]]; then
  if rg -n 'IpcHandler|function toggle\\s*\\(' "$PLUGIN_DIR/$MAIN_FILE" >/dev/null 2>&1; then
    HAS_IPC_TOGGLE=1
  fi
fi

echo "Prepared local test link:"
echo "  $TARGET_LINK -> $PLUGIN_DIR"
echo
echo "Validated:"
echo "  manifest.json"
echo "  README.md"
echo "  entryPoints referenced by manifest"
echo "  plugins.json state for local enablement"
echo
echo "Next manual steps in Noctalia:"
echo "  1. Open Settings -> Plugins"
echo "  2. Enable '$PLUGIN_ID' if it appears disabled"
echo "  3. If it has a bar widget, add it in Settings -> Bar"
echo "  4. If it has settings, open them from the Plugins tab or widget context"

if [[ "$HAS_IPC_TOGGLE" -eq 1 ]]; then
  echo
  echo "Possible manual IPC check:"
  echo "  qs -c noctalia-shell ipc call plugin:$PLUGIN_ID toggle"
fi
