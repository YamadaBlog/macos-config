#!/bin/bash
# Shared helpers for the repo scripts. Sourced, never run on its own.
set -u
REPO="$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC2034  # used by the scripts that source this file
STATE="$HOME/.local/state/macos-power-user-deploy"
export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/opt/homebrew/bin:$PATH"
export HOMEBREW_NO_AUTO_UPDATE=1
SECRET_RE='(api[_-]?key|secret|password|passwd|bearer|private[_-]?key|"token"|^token *=|<key>token</key>|<key>license)'

# shellcheck disable=SC2088  # literal "~/" prefix match, expanded below
expand() { case "$1" in "~/"*) printf '%s\n' "$HOME/${1#\~/}";; *) printf '%s\n' "$1";; esac; }

# Rows of tools/configs.tsv of type file|plist: id type live repo apply note
config_rows() { awk -F'\t' 'NR>1 && ($2=="file" || $2=="plist")' "$REPO/tools/configs.tsv"; }

has_secret() { grep -qiE "$SECRET_RE" "$1"; }

# Export a preferences domain as cleaned XML to $2. Exit code 1 if the domain does not exist.
export_plist() {
  defaults export "$1" - 2>/dev/null | plutil -convert xml1 -o "$2" - 2>/dev/null || return 1
  for k in remote_id remote_token device_id 'NSWindow Frame'; do plutil -remove "$k" "$2" 2>/dev/null || true; done
  case "$1" in pl.maketheweb.TopNotch|fyi.lunar.Lunar|eu.exelban.Stats)
    # Volatile or usage keys (dates, counters, positions, Sparkle SU*, usage history): no configuration
    # value, sometimes close to identifiers. plistlib also reads <data> fields (the former JSON conversion
    # failed silently on them and removed nothing).
    python3 -I - "$2" <<'PY' || return 1
import plistlib, sys
p = sys.argv[1]
d = plistlib.load(open(p, "rb"))
motifs = ("date", "last", "count", "frame", "position", "sparkle", "version", "usage", "timestamp")
for k in [k for k in d if k.startswith("SU") or any(m in k.lower() for m in motifs)]:
    del d[k]
plistlib.dump(d, open(p, "wb"), fmt=plistlib.FMT_XML)
PY
    ;;
  esac
}

# Write to $1 the machine's version of a config row. Exit code 1 if it does not exist.
live_copy() {
  local out="$1" type="$2" live="$3"
  if [ "$type" = file ]; then live="$(expand "$live")"; [ -f "$live" ] || return 1; cp "$live" "$out"
  else export_plist "$live" "$out"; fi
}
