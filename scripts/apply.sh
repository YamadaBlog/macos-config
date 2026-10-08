#!/bin/bash
# APPLICATION dépôt -> poste, un outil à la fois.
#   scripts/apply.sh <id>            aperçu (diff), n'écrit rien
#   scripts/apply.sh <id> --write    sauvegarde le fichier vivant puis applique
#   scripts/apply.sh --list          ids disponibles (inventory/configs.tsv)
# Sauvegardes : ~/.local/state/macos-power-user-deploy/backups/apply-<date>/<chemin d'origine>
# Retour arrière : la commande exacte est affichée après chaque écriture.
. "$(dirname "$0")/lib.sh"
id="${1:-}"; write=0; [ "${2:-}" = --write ] && write=1
if [ -z "$id" ] || [ "$id" = --list ]; then awk -F'\t' 'NR>1 {print $1"\t"$2"\t"$5}' "$REPO/inventory/configs.tsv" | sort -u; exit 0; fi
bk="$STATE/backups/apply-$(date +%Y%m%d-%H%M%S)"

case "$id" in
  home-manager)
    cd "$REPO/home-manager" || exit 2
    nix build '.#homeConfigurations.mac.activationPackage' --out-link result-home || exit 1
    echo "Construit : $(readlink result-home)"; echo "Active    : $(readlink -f "$HOME/.local/state/nix/profiles/home-manager")"
    [ "$write" = 1 ] || { echo "Aperçu seulement (--write pour activer)."; exit 0; }
    prev="$(readlink -f "$HOME/.local/state/nix/profiles/home-manager")"
    ./result-home/activate || exit 1
    echo "Retour : $prev/activate"; exit 0;;
  homebrew)
    brew bundle check --file="$REPO/homebrew/Brewfile" --verbose
    [ "$write" = 1 ] && brew bundle install --no-upgrade --file="$REPO/homebrew/Brewfile"
    echo "Aucune désinstallation automatique ; retrait d'une app : brew uninstall --cask <app>."; exit 0;;
esac

rows="$(awk -F'\t' -v id="$id" 'NR>1 && $1==id && ($2=="file"||$2=="plist")' "$REPO/inventory/configs.tsv")"
[ -n "$rows" ] || { echo "Id inconnu : $id (voir --list)" >&2; exit 2; }
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
while IFS=$'\t' read -r _ type live dest how _; do
  [ -f "$REPO/$dest" ] || { echo "Pas de copie dans le dépôt : $dest"; continue; }
  if live_copy "$tmp/cur" "$type" "$live" && cmp -s "$tmp/cur" "$REPO/$dest"; then echo "identique  $live"; continue; fi
  echo "---- $live"; [ -f "$tmp/cur" ] && diff -u "$tmp/cur" "$REPO/$dest" | sed -n '3,40p'
  [ "$write" = 1 ] || continue
  case "$how" in *app-quittee*)
    app="$(awk -F'\t' -v id="$id" 'NR>1 && $1==id {print $2}' "$REPO/inventory/elements.tsv")"
    if pgrep -xi "$app" >/dev/null 2>&1 || pgrep -x "$(echo "$app" | sed 's/ //g')" >/dev/null 2>&1; then echo "Refus : quitter $app avant d'appliquer." >&2; exit 1; fi;;
  esac
  mkdir -p "$bk"
  if [ "$type" = file ]; then
    l="$(expand "$live")"; mkdir -p "$bk$(dirname "$l")"
    [ -f "$l" ] && cp -p "$l" "$bk$l"
    mkdir -p "$(dirname "$l")"; cp "$REPO/$dest" "$l"
    echo "appliqué. Retour : cp \"$bk$l\" \"$l\""
  else
    defaults export "$live" "$bk/$live.plist" 2>/dev/null
    # import fusionne : vider le domaine d'abord pour obtenir exactement la copie du dépôt
    defaults delete "$live" 2>/dev/null; defaults import "$live" "$REPO/$dest"
    echo "appliqué. Retour : defaults delete $live && defaults import $live \"$bk/$live.plist\""
  fi
done <<< "$rows"
