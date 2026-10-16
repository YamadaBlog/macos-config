#!/bin/bash
# CAPTURE machine -> repo, in two steps so the reference is never overwritten silently.
#   scripts/capture.sh            prepare a capture in the private state directory and show the diffs
#   scripts/capture.sh --accept   copy the last prepared capture into the repo
#   scripts/capture.sh --accept <path>...   accept only these repo paths (the others stay pending)
# Refused: a file that probably contains a secret; a target path with uncommitted changes.
# Rollback after --accept: git -C <repo> checkout -- <file> (or git revert).
. "$(dirname "$0")/lib.sh"
stage="$STATE/capture-pending"
umask 077

if [ "${1:-}" = --accept ]; then
  [ -f "$stage/MANIFEST" ] || { echo "No prepared capture: run scripts/capture.sh" >&2; exit 2; }
  shift
  if [ "$#" -gt 0 ]; then
    : > "$stage/MANIFEST.sel"
    for want in "$@"; do awk -F'\t' -v w="$want" '$2==w' "$stage/MANIFEST" >> "$stage/MANIFEST.sel"; done
    [ -s "$stage/MANIFEST.sel" ] || { echo "None of these paths is in the prepared capture." >&2; exit 2; }
    awk -F'\t' 'NR==FNR{k[$2]=1; next} !($2 in k)' "$stage/MANIFEST.sel" "$stage/MANIFEST" > "$stage/MANIFEST.rest"
    mv "$stage/MANIFEST.sel" "$stage/MANIFEST.now"
  else
    cp "$stage/MANIFEST" "$stage/MANIFEST.now"; : > "$stage/MANIFEST.rest"
  fi
  paths=(); while IFS=$'\t' read -r _ dest; do paths+=("$dest"); done < "$stage/MANIFEST.now"
  dirty="$(cd "$REPO" && git status --porcelain -- "${paths[@]}" 2>/dev/null)"
  if [ -n "$dirty" ]; then echo "Refused: uncommitted changes on these paths:" >&2; echo "$dirty" >&2; exit 1; fi
  while IFS=$'\t' read -r src dest; do mkdir -p "$(dirname "$REPO/$dest")"; cp "$src" "$REPO/$dest"; echo "captured  $dest"; done < "$stage/MANIFEST.now"
  if [ -s "$stage/MANIFEST.rest" ]; then
    mv "$stage/MANIFEST.rest" "$stage/MANIFEST"; rm -f "$stage/MANIFEST.now"
    echo "Restent en attente :"; cut -f2 "$stage/MANIFEST" | sed 's/^/  /'
  else rm -rf "$stage"; fi
  echo "Review: git -C \"$REPO\" diff; then commit and add a CHANGELOG.md entry."
  exit 0
fi

rm -rf "$stage"; mkdir -p "$stage/files"; : > "$stage/MANIFEST"
n=0; refused=0
add() { # $1 prepared source, $2 repo path
  if [ -f "$REPO/$2" ] && cmp -s "$1" "$REPO/$2"; then return; fi
  if has_secret "$1"; then echo "REFUSÉ (secret probable) : $2" >&2; refused=1; return; fi
  echo "---- $2"; if [ -f "$REPO/$2" ]; then diff -u "$REPO/$2" "$1" | sed -n '3,60p'; else echo "(new file)"; fi
  printf '%s\t%s\n' "$1" "$2" >> "$stage/MANIFEST"; n=$((n+1))
}
i=0
while IFS=$'\t' read -r _ type live dest _ _; do
  i=$((i+1)); f="$stage/files/$i"
  live_copy "$f" "$type" "$live" && add "$f" "$dest"
done < <(config_rows)

echo; echo "$n file(s) to capture. Prepared in: $stage"
[ "$refused" = 1 ] && echo "Some files were refused: remove the secret or exclude the key in scripts/lib.sh."
[ "$n" -gt 0 ] && echo "Valider : scripts/capture.sh --accept"
exit 0
