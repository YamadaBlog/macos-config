#!/bin/bash
# CAPTURE poste -> dépôt, en deux temps pour ne jamais écraser la référence en silence.
#   scripts/capture.sh            prépare une capture dans l'état privé et affiche les diffs
#   scripts/capture.sh --accept   copie la dernière capture préparée dans le dépôt
#   scripts/capture.sh --accept <chemin>...   n'accepte que ces chemins du dépôt (les autres restent en attente)
# Refus : fichier contenant un secret probable ; chemin cible modifié et non commité.
# Retour arrière après --accept : git -C ~/dev/macos-config checkout -- <fichier> (ou git revert).
. "$(dirname "$0")/lib.sh"
stage="$STATE/capture-pending"
umask 077

if [ "${1:-}" = --accept ]; then
  [ -f "$stage/MANIFEST" ] || { echo "Aucune capture préparée : lancer scripts/capture.sh" >&2; exit 2; }
  shift
  if [ "$#" -gt 0 ]; then
    : > "$stage/MANIFEST.sel"
    for want in "$@"; do awk -F'\t' -v w="$want" '$2==w' "$stage/MANIFEST" >> "$stage/MANIFEST.sel"; done
    [ -s "$stage/MANIFEST.sel" ] || { echo "Aucun de ces chemins n'est dans la capture préparée." >&2; exit 2; }
    awk -F'\t' 'NR==FNR{k[$2]=1; next} !($2 in k)' "$stage/MANIFEST.sel" "$stage/MANIFEST" > "$stage/MANIFEST.rest"
    mv "$stage/MANIFEST.sel" "$stage/MANIFEST.now"
  else
    cp "$stage/MANIFEST" "$stage/MANIFEST.now"; : > "$stage/MANIFEST.rest"
  fi
  dirty="$(cd "$REPO" && git status --porcelain -- $(cut -f2 "$stage/MANIFEST.now") 2>/dev/null)"
  if [ -n "$dirty" ]; then echo "Refus : modifications non commitées sur ces chemins :" >&2; echo "$dirty" >&2; exit 1; fi
  while IFS=$'\t' read -r src dest; do mkdir -p "$(dirname "$REPO/$dest")"; cp "$src" "$REPO/$dest"; echo "capturé  $dest"; done < "$stage/MANIFEST.now"
  date '+%Y-%m-%d %H:%M' > "$REPO/docs/generated/last-sync.txt"
  if [ -s "$stage/MANIFEST.rest" ]; then
    mv "$stage/MANIFEST.rest" "$stage/MANIFEST"; rm -f "$stage/MANIFEST.now"
    echo "Restent en attente :"; cut -f2 "$stage/MANIFEST" | sed 's/^/  /'
  else rm -rf "$stage"; fi
  echo "Relire : git -C \"$REPO\" diff ; puis commit et entrée dans CHANGELOG.md."
  exit 0
fi

rm -rf "$stage"; mkdir -p "$stage/files"; : > "$stage/MANIFEST"
n=0; refused=0
add() { # $1 source préparée, $2 chemin dépôt
  if [ -f "$REPO/$2" ] && cmp -s "$1" "$REPO/$2"; then return; fi
  if has_secret "$1"; then echo "REFUSÉ (secret probable) : $2" >&2; refused=1; return; fi
  echo "---- $2"; if [ -f "$REPO/$2" ]; then diff -u "$REPO/$2" "$1" | sed -n '3,60p'; else echo "(nouveau fichier)"; fi
  printf '%s\t%s\n' "$1" "$2" >> "$stage/MANIFEST"; n=$((n+1))
}
i=0
while IFS=$'\t' read -r id type live dest _ _; do
  i=$((i+1)); f="$stage/files/$i"
  live_copy "$f" "$type" "$live" && add "$f" "$dest"
done < <(config_rows)
brew bundle dump --force --file="$stage/files/Brewfile" >/dev/null 2>&1 && add "$stage/files/Brewfile" homebrew/Brewfile
"$REPO/scripts/snapshot.sh" "$stage/files/gen" >/dev/null
for g in "$stage"/files/gen/*; do add "$g" "docs/generated/${g##*/}"; done

echo; echo "$n fichier(s) à capturer. Préparé dans : $stage"
[ "$refused" = 1 ] && echo "Des fichiers ont été refusés : retirer le secret ou exclure la clé dans scripts/lib.sh."
[ "$n" -gt 0 ] && echo "Valider : scripts/capture.sh --accept"
exit 0
