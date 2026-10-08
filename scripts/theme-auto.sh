#!/bin/bash
# Lancé par l'agent launchd « theme-auto » quand macOS modifie l'index des fonds d'écran.
# Si l'image affichée a réellement changé : régénère la palette, applique le thème, capture et commite
# les seuls fichiers liés au thème, puis notifie. Sinon : ne fait rien.
# Journal : ~/Library/Logs/macos-config/theme-auto.log   — Désactiver : launchctl bootout gui/$(id -u)/org.nix-community.home.theme-auto
export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin"
REPO="$HOME/dev/macos-config"
LOCK="${TMPDIR:-/tmp}/macos-config-theme-auto.lock"
exec >>"$HOME/Library/Logs/macos-config/theme-auto.log" 2>&1
mkdir "$LOCK" 2>/dev/null || { echo "$(date '+%F %T') déjà en cours, ignoré"; exit 0; }
IDX="$HOME/Library/Application Support/com.apple.wallpaper/Store/Index.plist"
debut="$(stat -f %m "$IDX")"
# launchd ne remet pas en file un changement survenu pendant l'exécution : on revérifie à la fin.
fin() { rmdir "$LOCK"; [ "$(stat -f %m "$IDX")" != "$debut" ] && { echo "$(date '+%F %T') index modifié pendant l'exécution : nouvelle passe"; exec /bin/bash "$0"; }; }
trap fin EXIT
sleep 3  # laisser macOS finir d'écrire l'index

src="$(python3 -I - "$HOME/Library/Application Support/com.apple.wallpaper/Store/Index.plist" <<'PY'
import plistlib, re, sys, urllib.parse
d = plistlib.load(open(sys.argv[1], "rb"))
def walk(o):
    if isinstance(o, dict):
        for v in o.values(): yield from walk(v)
    elif isinstance(o, list):
        for v in o: yield from walk(v)
    elif isinstance(o, bytes):
        try: yield from walk(plistlib.loads(o))
        except Exception:
            for m in re.findall(rb"file://[^\x00\"<]+", o): yield m.decode("utf-8", "replace")
    elif isinstance(o, str) and o.startswith("file://"): yield o
urls = [u for u in walk(d) if re.search(r"\.(png|jpe?g|heic|tiff?)$", u, re.I)]
print(urllib.parse.unquote(urls[0][7:]) if urls else "")
PY
)"
[ -n "$src" ] && [ -f "$src" ] || { echo "$(date '+%F %T') fond d'écran sans fichier image (dynamique/système) : ignoré"; exit 0; }
sum="$(shasum -a 256 "$src" | cut -c1-64)"
[ "$sum" = "$(cat "$REPO/wallpapers/source.sha256" 2>/dev/null)" ] && exit 0

echo "$(date '+%F %T') nouveau fond d'écran : $src"
"$REPO/scripts/theme-sync.sh" || { echo "échec theme-sync"; osascript -e 'display notification "Échec de l’adaptation du thème (voir ~/Library/Logs/macos-config/theme-auto.log)" with title "Thème"'; exit 1; }
echo "$sum" > "$REPO/wallpapers/source.sha256"
"$REPO/scripts/capture.sh" >/dev/null
# N'accepter que les fichiers liés au thème ; le reste éventuel reste en attente de relecture.
"$REPO/scripts/capture.sh" --accept tools/neru/config/config.toml tools/omniwm/config/settings.toml docs/generated/macos-defaults.tsv 2>/dev/null
cd "$REPO" && git add wallpapers home-manager/palette.nix tools/neru/config/config.toml tools/omniwm/config/settings.toml docs/generated/macos-defaults.tsv docs/generated/last-sync.txt \
  && git commit -qm "auto: thème depuis le fond d'écran $(basename "$src")" && echo "commit $(git log --format=%h -1)"
scheme="$(sed -n 's/.*scheme = "\(.*\)"; author.*/\1/p' "$REPO/home-manager/palette.nix")"
osascript -e "display notification \"Palette « $scheme » appliquée\" with title \"Thème adapté au fond d’écran\""
