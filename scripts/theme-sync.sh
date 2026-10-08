#!/bin/bash
# Synchronise le thème du poste avec le fond d'écran.
#   scripts/theme-sync.sh            reprend le fond d'écran affiché par macOS dans wallpapers/actuel.png, puis applique
#   scripts/theme-sync.sh --no-copy  applique la palette de home-manager/theme.nix sans changer d'image
# La palette home-manager/palette.nix est régénérée depuis l'image par scripts/palette-from-image.py (accents distincts).
# OmniWM recharge settings.toml à chaud : il n'est pas quitté (aucun AppleScript → aucune autorisation Automatisation).
. "$(dirname "$0")/lib.sh"
set -e
if [ "${1:-}" != --no-copy ]; then
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
  [ -n "$src" ] && [ -f "$src" ] || { echo "Fond d'écran actuel introuvable (image dynamique ou système ?)." >&2; exit 2; }
  tmpimg="$(mktemp -d)/w.png"; sips -s format png "$src" --out "$tmpimg" >/dev/null
  if cmp -s "$tmpimg" "$REPO/wallpapers/actuel.png"; then echo "fond d'écran : inchangé"
  else cp "$tmpimg" "$REPO/wallpapers/actuel.png"; echo "fond d'écran : copié depuis $src"; fi
  python3 -I "$REPO/scripts/palette-from-image.py" "$REPO/wallpapers/actuel.png" "$REPO/home-manager/palette.nix" "$(basename "${src%.*}") (auto)"
fi
( cd "$REPO" && git add wallpapers home-manager )
"$REPO/scripts/apply.sh" home-manager --write | tail -1
"$REPO/scripts/theme-apply.sh" --write
cp -p "$HOME/.config/omniwm/settings.toml" "$STATE/backups/omniwm-$(date +%Y%m%d-%H%M%S)-theme-sync.toml"
python3 -I "$REPO/tools/omniwm/apply-registry.py" "$HOME/.config/omniwm/settings.toml" --write </dev/null | tail -1  # rechargé à chaud
hs=/Applications/Hammerspoon.app/Contents/Frameworks/hs/hs
( "$hs" -c 'hs.timer.doAfter(0.2, function() local g=hs.application.get("com.mitchellh.ghostty"); if g then g:selectMenuItem({"Ghostty","Reload Configuration"}) end; hs.reload() end)' & p=$!; sleep 4; kill $p ) >/dev/null 2>&1 || true
echo "Thème appliqué. Relire puis capturer : scripts/capture.sh && scripts/capture.sh --accept ; commit."
