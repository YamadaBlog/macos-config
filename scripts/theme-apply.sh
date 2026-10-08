#!/bin/bash
# Applique la palette Stylix (~/.config/stylix/palette.json, générée par Home Manager) aux outils hors Stylix.
#   scripts/theme-apply.sh            aperçu (n'écrit rien)
#   scripts/theme-apply.sh --write    sauvegarde puis applique : Neru [theme.dark], bordure OmniWM, accent macOS
# Ordre normal : scripts/apply.sh home-manager --write  puis  scripts/theme-apply.sh --write
. "$(dirname "$0")/lib.sh"
write=0; [ "${1:-}" = --write ] && write=1
pal="$HOME/.config/stylix/palette.json"
[ -f "$pal" ] || { echo "Palette absente : appliquer d'abord Home Manager." >&2; exit 2; }
bk="$STATE/backups/theme-apply-$(date +%Y%m%d-%H%M%S)"

# --- Neru : section [theme.dark] (fond, accents, texte)
neru_cfg="$HOME/.config/neru/config.toml"
python3 -I - "$pal" "$neru_cfg" "$write" <<'PY'
import json, re, sys
pal, cfg, write = json.load(open(sys.argv[1])), sys.argv[2], sys.argv[3] == "1"
c = lambda k: "#" + pal[k].upper()
want = {"surface": c("base00"), "accent": c("base0D"), "accent_alt": c("base0C"),
        "on_accent_alt": c("base00"), "text": c("base05")}
lines, section, changes = open(cfg).read().split("\n"), None, 0
for i, l in enumerate(lines):
    if l.startswith("["): section = l.strip()
    m = re.match(r'^(\w+) = "(#[0-9A-Fa-f]{6})"', l)
    if section == "[theme.dark]" and m and m.group(1) in want and m.group(2).upper() != want[m.group(1)]:
        print(f"neru  {m.group(1)}: {m.group(2)} -> {want[m.group(1)]}"); lines[i] = f'{m.group(1)} = "{want[m.group(1)]}"'; changes += 1
if write and changes: open(cfg, "w").write("\n".join(lines))
print(f"neru  {changes} changement(s)")
PY
if [ "$write" = 1 ]; then mkdir -p "$bk"; cp -p "$neru_cfg" "$bk/neru-config.toml" 2>/dev/null; neru config validate >/dev/null && neru config reload >/dev/null 2>&1; fi

# --- OmniWM : couleur de bordure (même si la bordure est désactivée, par cohérence) = base0D (accent)
python3 -I - "$pal" "$REPO/tools/omniwm/apply-registry.py" <<'PY'
import json, sys
pal = json.load(open(sys.argv[1])); h = pal["base0D"]
r, g, b = (round(int(h[i:i+2], 16) / 255, 4) for i in (0, 2, 4))
print(f"omniwm bordure base0D #{h} -> red={r} green={g} blue={b} (appliqué par apply-registry.py)")
PY

# --- Accent macOS : 8 couleurs fixes ; on prend la plus proche de l'accent du thème (base0D)
read -r target name hl <<<"$(python3 -I - "$pal" <<'PY'
import json, sys
h = json.load(open(sys.argv[1]))["base0D"]; rgb = tuple(int(h[i:i+2], 16) for i in (0, 2, 4))
# Valeurs de référence des accents macOS (approx.) : n°, nom, couleur, chaîne AppleHighlightColor
acc = [(0, "Red", (255, 82, 89), "1.000000 0.733333 0.721569 Red"), (1, "Orange", (247, 130, 27), "1.000000 0.874510 0.701961 Orange"),
       (2, "Yellow", (255, 199, 38), "1.000000 0.937255 0.690196 Yellow"), (3, "Green", (98, 186, 70), "0.752941 0.964706 0.678431 Green"),
       (4, "Blue", (0, 122, 255), "0.698039 0.843137 1.000000 Blue"), (5, "Purple", (165, 80, 167), "0.968627 0.831373 1.000000 Purple"),
       (6, "Pink", (247, 79, 158), "1.000000 0.749020 0.823529 Pink"), (-1, "Graphite", (140, 140, 140), "0.847059 0.847059 0.862745 Graphite")]
# Comparaison par TEINTE (la distance RGB choisissait Graphite pour un bleu moyen) ; Graphite si couleur quasi grise.
import colorsys
hh, ll, ss = colorsys.rgb_to_hls(*(c / 255 for c in rgb))
if ss < 0.15:
    best = acc[-1]
else:
    def hue(a):
        return colorsys.rgb_to_hls(*(c / 255 for c in a[2]))[0]
    best = min(acc[:-1], key=lambda a: min(abs(hue(a) - hh), 1 - abs(hue(a) - hh)))
print(best[0], best[1], best[3].replace(" ", "_"))
PY
)"
hl="${hl//_/ }"
cur="$(defaults read -g AppleAccentColor 2>/dev/null || echo absent)"
echo "accent macOS : actuel=$cur cible=$target ($name, la plus proche de base0D)"
if [ "$write" = 1 ] && [ "$cur" != "$target" ]; then
  mkdir -p "$bk"; echo "AppleAccentColor=$cur AppleHighlightColor=$(defaults read -g AppleHighlightColor 2>/dev/null || echo absent)" > "$bk/accent-avant.txt"
  defaults write -g AppleAccentColor -int "$target"
  defaults write -g AppleHighlightColor -string "$hl"
  echo "accent appliqué (effet complet après relance des apps). Retour : $bk/accent-avant.txt"
fi
[ "$write" = 1 ] || echo "Aperçu seulement (--write pour appliquer)."
