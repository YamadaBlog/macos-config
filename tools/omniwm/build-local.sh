#!/bin/bash
# Build the local OmniWM (branch of ~/dev/omniwm) and install it as /Applications/OmniWM.app,
# signed with the local certificate "OmniWM Local Signing" so macOS keeps Accessibility and
# Input Monitoring across rebuilds (designated requirement = bundle id + certificate leaf).
#   tools/omniwm/build-local.sh [branch]       default: current branch of ~/dev/omniwm
# Certificate: self-signed, login keychain, usable by /usr/bin/codesign only (created 2026-10-09).
# Rollback to official app: ~/.local/state/macos-power-user-deploy/backups/OmniWM-officiel-0.7.6.app
set -euo pipefail
SRC="$HOME/dev/omniwm"; CERT="OmniWM Local Signing"
[ -n "${1:-}" ] && git -C "$SRC" checkout -q "$1"
hash="$(security find-identity -p codesigning | awk -v n="\"$CERT\"" 'index($0,n){print $2; exit}')"
[ -n "$hash" ] || { echo "Certificate \"$CERT\" missing from the login keychain." >&2; exit 2; }
cd "$SRC"
echo "Building $(git rev-parse --abbrev-ref HEAD) @ $(git rev-parse --short HEAD)"
OMNIWM_SIGNING_IDENTITY="$CERT" Scripts/package-app.sh release dev >/dev/null
app="$SRC/dist/OmniWM.app"
codesign --force --sign "$hash" "$app/Contents/MacOS/omniwmctl"
codesign --force --entitlements "$SRC/OmniWM.entitlements" --sign "$hash" "$app/Contents/MacOS/OmniWM"
codesign --force --entitlements "$SRC/OmniWM.entitlements" --sign "$hash" "$app"
codesign --verify "$app"
codesign -dr - "$app" 2>&1 | grep -q "certificate leaf = H\"$(echo "$hash" | tr 'A-F' 'a-f')\"" \
  || { echo "Designated requirement does not pin the certificate: aborting." >&2; exit 1; }
pkill -x OmniWM || true; sleep 2
rm -rf /Applications/OmniWM.app && ditto "$app" /Applications/OmniWM.app
open -g -a OmniWM
echo "Installed /Applications/OmniWM.app (signed by \"$CERT\")"
