#!/bin/bash
# Publish a sanitized snapshot of this repo to the public GitHub repo (remote "public").
#   scripts/publish.sh            preview: build the snapshot, scan it, show what would change
#   scripts/publish.sh --push     same, then commit on top of public/main and push
# The local history is NEVER pushed (it contains a machine hostname and old usage data):
# each publish adds one commit to the public history with the GitHub no-reply identity.
. "$(dirname "$0")/lib.sh"
set -euo pipefail
push=0; [ "${1:-}" = --push ] && push=1
URL="https://github.com/YamadaBlog/macos-config.git"
ID_NAME="YamadaBlog"; ID_MAIL="118530756+YamadaBlog@users.noreply.github.com"
PRIVATE_MAIL_RE='mao@mac\.[a-z0-9]+\.ts\.net'
work="$STATE/publish"; tree="$work/tree"
cred=(-c credential.helper= -c 'credential.helper=!gh auth git-credential')

[ -z "$(git -C "$REPO" status --porcelain)" ] || { echo "Uncommitted changes: commit first." >&2; exit 2; }

# 1. Public clone (kept between runs)
if [ -d "$work/public/.git" ]; then git -C "$work/public" "${cred[@]}" fetch -q origin && git -C "$work/public" reset -q --hard origin/main
else rm -rf "$work/public"; mkdir -p "$work"; git "${cred[@]}" clone -q "$URL" "$work/public"; fi

# 2. Sanitized tree from local HEAD
rm -rf "$tree"; mkdir -p "$tree"
git -C "$REPO" archive HEAD | tar -x -C "$tree"
rm -f "$tree"/wallpapers/*.png "$tree"/wallpapers/*.jpg
find "$tree" -type f -name '*.patch' -exec sed -i '' -E "s/$PRIVATE_MAIL_RE/$ID_MAIL/g" {} +
printf '\n# Wallpapers: third-party images, not published (unknown rights)\nwallpapers/*.png\nwallpapers/*.jpg\n' >> "$tree/.gitignore"
printf "# Wallpapers\nImages are not published (unknown copyright).\n\`scripts/theme-sync.sh\` copies the current macOS wallpaper here (\`actuel.png\`) and derives the palette from it.\n" > "$tree/wallpapers/README.md"

# 3. Checks: private identifiers, then gitleaks
if grep -rIlE "$PRIVATE_MAIL_RE|[a-z0-9-]+\.ts\.net" "$tree"; then echo "Private identifier found above: aborting." >&2; exit 1; fi
nix run nixpkgs#gitleaks -- dir --no-banner --redact "$tree" >/dev/null 2>&1 || { echo "gitleaks found something: run it on $tree, aborting." >&2; exit 1; }
echo "gitleaks: no leaks"

# 4. Replace the public working tree with the snapshot and show the change
pub="$work/public"
git -C "$pub" rm -rq --cached . >/dev/null 2>&1 || true
find "$pub" -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
cp -R "$tree"/. "$pub"/
git -C "$pub" add -A
if git -C "$pub" diff --cached --quiet; then echo "Public repo already up to date."; exit 0; fi
git -C "$pub" diff --cached --stat | tail -15
[ "$push" = 1 ] || { echo "Preview only (--push to publish)."; exit 0; }

msg="Sync from local $(git -C "$REPO" rev-parse --short HEAD): $(git -C "$REPO" log -1 --format=%s)"
GIT_AUTHOR_NAME="$ID_NAME" GIT_AUTHOR_EMAIL="$ID_MAIL" GIT_COMMITTER_NAME="$ID_NAME" GIT_COMMITTER_EMAIL="$ID_MAIL" \
  git -C "$pub" commit -qm "$msg"
git -C "$pub" "${cred[@]}" push -q origin main
git -C "$REPO" fetch -q public 2>/dev/null || true
echo "Published: $(git -C "$pub" rev-parse --short HEAD) — https://github.com/YamadaBlog/macos-config"
