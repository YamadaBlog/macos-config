#!/bin/bash
# APPLY repo -> machine, one tool at a time.
#   scripts/apply.sh <id>            preview (diff), writes nothing
#   scripts/apply.sh <id> --write    back up the live file, then apply
#   scripts/apply.sh --list          available ids (tools/configs.tsv)
# Backups: ~/.local/state/macos-power-user-deploy/backups/apply-<date>/<original path>
# Rollback: the exact command is printed after each write.
. "$(dirname "$0")/lib.sh"
id="${1:-}"; write=0; [ "${2:-}" = --write ] && write=1
if [ -z "$id" ] || [ "$id" = --list ]; then awk -F'\t' 'NR>1 {print $1"\t"$2"\t"$5}' "$REPO/tools/configs.tsv" | sort -u; exit 0; fi
bk="$STATE/backups/apply-$(date +%Y%m%d-%H%M%S)"

case "$id" in
  home-manager)
    cd "$REPO/home-manager" || exit 2
    # identity.nix reads USER, HOME and MACOS_CONFIG_REPO: impure on purpose (no personal value in the repo).
    MACOS_CONFIG_REPO="$REPO" nix build --impure '.#homeConfigurations.mac.activationPackage' --out-link result-home || exit 1
    echo "Built:  $(readlink result-home)"; echo "Active: $(readlink -f "$HOME/.local/state/nix/profiles/home-manager")"
    [ "$write" = 1 ] || { echo "Preview only (--write to activate)."; exit 0; }
    prev="$(readlink -f "$HOME/.local/state/nix/profiles/home-manager")"
    ./result-home/activate || exit 1
    echo "Rollback: $prev/activate"; exit 0;;
  homebrew)
    brew bundle check --file="$REPO/homebrew/Brewfile" --verbose
    [ "$write" = 1 ] && brew bundle install --no-upgrade --file="$REPO/homebrew/Brewfile"
    echo "Nothing is ever uninstalled automatically; to remove an app: brew uninstall --cask <app>."; exit 0;;
esac

rows="$(awk -F'\t' -v id="$id" 'NR>1 && $1==id && ($2=="file"||$2=="plist")' "$REPO/tools/configs.tsv")"
[ -n "$rows" ] || { echo "Unknown id: $id (see --list)" >&2; exit 2; }
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
while IFS=$'\t' read -r _ type live dest how _; do
  [ -f "$REPO/$dest" ] || { echo "No copy in the repo: $dest"; continue; }
  if live_copy "$tmp/cur" "$type" "$live" && cmp -s "$tmp/cur" "$REPO/$dest"; then echo "identical  $live"; continue; fi
  echo "---- $live"; [ -f "$tmp/cur" ] && diff -u "$tmp/cur" "$REPO/$dest" | sed -n '3,40p'
  [ "$write" = 1 ] || continue
  case "$how" in *app-quit*)
    case "$id" in omniwm) app=OmniWM;; stats) app=Stats;; neru) app=Neru;; *) app="$id";; esac
    if pgrep -xi "$app" >/dev/null 2>&1 || pgrep -x "$(echo "$app" | sed 's/ //g')" >/dev/null 2>&1; then echo "Refused: quit $app before applying." >&2; exit 1; fi;;
  esac
  mkdir -p "$bk"
  if [ "$type" = file ]; then
    l="$(expand "$live")"; mkdir -p "$bk$(dirname "$l")"
    [ -f "$l" ] && cp -p "$l" "$bk$l"
    mkdir -p "$(dirname "$l")"; cp "$REPO/$dest" "$l"
    echo "applied. Rollback: cp \"$bk$l\" \"$l\""
  else
    defaults export "$live" "$bk/$live.plist" 2>/dev/null
    # import merges: empty the domain first to get exactly the repo copy
    defaults delete "$live" 2>/dev/null; defaults import "$live" "$REPO/$dest"
    echo "applied. Rollback: defaults delete $live && defaults import $live \"$bk/$live.plist\""
  fi
done <<< "$rows"
