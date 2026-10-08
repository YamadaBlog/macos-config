#!/bin/bash
# VÉRIFICATION (lecture seule) : couverture de l'inventaire + écarts poste/dépôt.
#   scripts/verify.sh            couverture + configs + instantanés
#   scripts/verify.sh --hm       ajoute : la flake construit-elle la génération active ?
# Code de sortie : 0 = conforme ; 1 = manque ou écart.
. "$(dirname "$0")/lib.sh"
rc=0; tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT

echo "== Couverture (installé sur le poste mais absent de inventory/elements.tsv)"
awk -F'\t' 'NR>1 {n=split($17,k,","); for(i=1;i<=n;i++) if(k[i]!="") print k[i]}' "$REPO/inventory/elements.tsv" | sort -u > "$tmp/known"
awk -F'\t' 'NR>1 {print $1}' "$REPO/inventory/ignore.tsv" > "$tmp/ignore"
"$REPO/scripts/discover.sh" > "$tmp/found"
missing=0
while read -r key; do
  grep -qxF "$key" "$tmp/known" && continue
  skip=0; while read -r pat; do case "$key" in $pat) skip=1; break;; esac; done < "$tmp/ignore"
  [ "$skip" = 1 ] && continue
  echo "  NON INVENTORIÉ  $key"; missing=1
done < "$tmp/found"
# Sens inverse : élément inventorié dont aucune clé n'est plus détectée
awk -F'\t' 'NR>1 && $17!="" {print $1"\t"$17}' "$REPO/inventory/elements.tsv" | while IFS=$'\t' read -r id keys; do
  hit=0; IFS=',' read -ra arr <<< "$keys"; for k in "${arr[@]}"; do grep -qxF "$k" "$tmp/found" && { hit=1; break; }; done
  [ "$hit" = 0 ] && echo "  DISPARU         $id ($keys)"
done | tee "$tmp/gone"
[ -s "$tmp/gone" ] && missing=1
[ "$missing" = 0 ] && echo "  ok : tout élément détecté est inventorié"
[ "$missing" = 1 ] && rc=1

echo "== Fiches (chaque élément inventorié a une fiche existante)"
awk -F'\t' 'NR>1 {print $1"\t"$16}' "$REPO/inventory/elements.tsv" | while IFS=$'\t' read -r id fiche; do
  [ -f "$REPO/$fiche" ] || echo "  FICHE ABSENTE  $id -> $fiche"
done | tee "$tmp/nofiche"
[ -s "$tmp/nofiche" ] && rc=1 || echo "  ok : toutes les fiches existent"

echo "== Permissions TCC (inventory/permissions.tsv ; tiers uniquement)"
q="select service||char(9)||client||char(9)||auth_value from access where client not like 'com.apple.%'"
if { sqlite3 -readonly "/Library/Application Support/com.apple.TCC/TCC.db" "$q"; sqlite3 -readonly "$HOME/Library/Application Support/com.apple.TCC/TCC.db" "$q"; } > "$tmp/tcc" 2>/dev/null; then
  # Lignes « RÉSIDU » : hors conformité (leur présence ou leur suppression ne change pas le résultat), rapportées à part.
  awk -F'\t' 'NR>1 && $4 !~ /^RÉSIDU/ {print $1"\t"$2"\t"$3}' "$REPO/inventory/permissions.tsv" | sort > "$tmp/tcc-exp"
  awk -F'\t' 'NR>1 && $4 ~ /^RÉSIDU/ {print $1"\t"$2}' "$REPO/inventory/permissions.tsv" | sort -u > "$tmp/tcc-res"
  awk -F'\t' 'NR==FNR{r[$1"\t"$2]=1; next} !(($1"\t"$2) in r)' "$tmp/tcc-res" "$tmp/tcc" | sort > "$tmp/tcc-real"
  awk -F'\t' 'NR==FNR{r[$1"\t"$2]=1; next} (($1"\t"$2) in r)' "$tmp/tcc-res" "$tmp/tcc" | while IFS=$'\t' read -r sv cl av; do
    if [ "$av" = 0 ]; then echo "  résidu présent, refusé (nettoyage facultatif) : $sv $cl"
    elif [ "${cl#/nix/store/}" != "$cl" ]; then echo "  ALERTE SÉCURITÉ, résidu ACCORDÉ (hors conformité, à supprimer) : $sv $cl"
    else echo "  résidu présent, accordé à une app absente (nettoyage) : $sv $cl"; fi
  done
  if cmp -s "$tmp/tcc-exp" "$tmp/tcc-real"; then echo "  ok : permissions conformes"
  else
    # Une entrée inattendue mais REFUSÉE (auth_value 0) n'accorde rien : résidu signalé, pas un écart de conformité.
    comm -13 "$tmp/tcc-exp" "$tmp/tcc-real" > "$tmp/tcc-new"
    awk -F'\t' '$3=="0"' "$tmp/tcc-new" | sed 's|^|  RÉSIDU REFUSÉ (nettoyage facultatif, sans effet)  |'
    awk -F'\t' '$3!="0"' "$tmp/tcc-new" | sed 's|^|  NOUVELLE OU MODIFIÉE (accordée)  |' | tee "$tmp/tcc-granted"
    comm -23 "$tmp/tcc-exp" "$tmp/tcc-real" | sed 's|^|  ATTENDUE ABSENTE  |' | tee "$tmp/tcc-missing"
    if [ -s "$tmp/tcc-granted" ] || [ -s "$tmp/tcc-missing" ]; then rc=1; else echo "  ok : aucune autorisation effective inattendue"; fi
  fi
else echo "  non vérifiable : base TCC illisible (Accès complet au disque requis pour le terminal)"; fi

echo "== Configurations (poste vs dépôt)"
while IFS=$'\t' read -r id type live dest _ _; do
  if ! live_copy "$tmp/cur" "$type" "$live"; then echo "  absent   $id  $live"; continue; fi
  if [ ! -f "$REPO/$dest" ]; then echo "  NON CAPTURÉ  $id  $dest"; rc=1
  elif cmp -s "$tmp/cur" "$REPO/$dest"; then echo "  ok       $id  $dest"
  else echo "  ÉCART    $id  $dest  (diff : scripts/capture.sh)"; rc=1; fi
done < <(config_rows)

echo "== Homebrew"
brew bundle dump --force --file="$tmp/Brewfile" >/dev/null 2>&1
if cmp -s "$tmp/Brewfile" "$REPO/homebrew/Brewfile"; then echo "  ok       homebrew/Brewfile"; else echo "  ÉCART    homebrew/Brewfile"; diff "$REPO/homebrew/Brewfile" "$tmp/Brewfile" | sed 's/^/    /'; rc=1; fi

echo "== Instantanés générés"
"$REPO/scripts/snapshot.sh" "$tmp/gen" >/dev/null
for f in "$tmp"/gen/*; do
  b="${f##*/}"
  if cmp -s "$f" "$REPO/docs/generated/$b"; then echo "  ok       docs/generated/$b"; else echo "  ÉCART    docs/generated/$b"; rc=1; fi
done

if [ "${1:-}" = --hm ]; then
  echo "== Home Manager"
  out="$(cd "$REPO/home-manager" && nix build '.#homeConfigurations.mac.activationPackage' --no-link --print-out-paths 2>/dev/null)"
  active="$(readlink -f "$HOME/.local/state/nix/profiles/home-manager" 2>/dev/null)"
  if [ -n "$out" ] && [ "$out" = "$active" ]; then echo "  ok       génération active = flake ($out)"
  else echo "  ÉCART    flake=$out active=$active (appliquer : scripts/apply.sh home-manager --write)"; rc=1; fi
fi
exit "$rc"
