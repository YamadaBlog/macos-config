#!/bin/bash
# Fonctions communes aux scripts du dépôt. Sourcé, jamais exécuté seul.
set -u
REPO="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
STATE="$HOME/.local/state/macos-power-user-deploy"
export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/opt/homebrew/bin:$PATH"
export HOMEBREW_NO_AUTO_UPDATE=1
SECRET_RE='(api[_-]?key|secret|password|passwd|bearer|private[_-]?key|"token"|^token *=|<key>token</key>|<key>license)'
# Clés de plist retirées à l'export (identifiants d'appareil, fenêtres)
PLIST_DROP="remote_id remote_token device_id NSWindow\\ Frame"

expand() { case "$1" in "~/"*) printf '%s\n' "$HOME/${1#\~/}";; *) printf '%s\n' "$1";; esac; }

# Lignes de inventory/configs.tsv de type file|plist : id type vivant depot appliquer note
config_rows() { awk -F'\t' 'NR>1 && ($2=="file" || $2=="plist")' "$REPO/inventory/configs.tsv"; }

has_secret() { grep -qiE "$SECRET_RE" "$1"; }

# Exporte un domaine de préférences en XML nettoyé vers $2. Code 1 si domaine absent.
export_plist() {
  defaults export "$1" - 2>/dev/null | plutil -convert xml1 -o "$2" - 2>/dev/null || return 1
  for k in remote_id remote_token device_id 'NSWindow Frame'; do plutil -remove "$k" "$2" 2>/dev/null || true; done
  case "$1" in pl.maketheweb.TopNotch|fyi.lunar.Lunar|eu.exelban.Stats)
    # Clés volatiles ou d'usage (dates, compteurs, positions, Sparkle SU*, historiques d'usage) :
    # sans valeur de configuration, parfois quasi-identifiantes. plistlib lit aussi les champs <data>
    # (l'ancienne conversion JSON échouait en silence sur ces champs et ne retirait rien).
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

# Produit dans $1 la version « poste » d'une ligne de config. Code 1 si absente.
live_copy() {
  local out="$1" type="$2" live="$3"
  if [ "$type" = file ]; then live="$(expand "$live")"; [ -f "$live" ] || return 1; cp "$live" "$out"
  else export_plist "$live" "$out"; fi
}
