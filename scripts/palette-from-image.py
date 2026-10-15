#!/usr/bin/env python3
"""Palette base16 LISIBLE depuis une image (sans dépendance : sips + bibliothèque standard).

Usage : python3 -I scripts/palette-from-image.py <image> <sortie.nix> [nom]

Principe (la génération brute de Stylix donnait 8 accents de même teinte) :
- fond (base00-03) : teinte dominante des zones sombres de l'image, assombrie et désaturée ;
- texte (base04-07) : teinte dominante des zones claires, très claire et peu saturée ;
- accents (base08-0F) : une famille de teinte fixe par rôle (rouge, orange, or, vert, cyan, bleu, violet, brun)
  pour rester distincts, chacune attirée (±20°) vers la teinte réellement présente dans l'image si elle existe ;
- contraste WCAG >= 4,5:1 de chaque accent et du texte sur le fond (luminosité relevée si besoin).
"""
import colorsys
import math
import os
import struct
import subprocess
import sys
import tempfile

ROLES = [  # (clé, teinte cible en degrés, saturation, luminosité HLS, commentaire)
    ("base08", 355, 0.75, 0.66, "rouge : erreurs, suppressions"),
    ("base09", 28, 0.80, 0.64, "orange : constantes"),
    ("base0A", 45, 0.85, 0.70, "or : avertissements"),
    ("base0B", 140, 0.45, 0.62, "vert : succès, ajouts, chaînes"),
    ("base0C", 185, 0.60, 0.64, "cyan : échappements, info"),
    ("base0D", 212, 0.65, 0.62, "bleu : fonctions, liens, accent du poste"),
    ("base0E", 275, 0.55, 0.72, "violet : mots-clés"),
    ("base0F", 25, 0.45, 0.55, "brun : obsolète"),
]


def pixels(path):
    """Réduit l'image à 96x54 en BMP 24 bits via sips, renvoie la liste des (r, g, b) en 0..1."""
    with tempfile.TemporaryDirectory() as d:
        bmp = os.path.join(d, "p.bmp")
        subprocess.run(["sips", "-s", "format", "bmp", "-z", "54", "96", path, "--out", bmp],
                       check=True, capture_output=True)
        data = open(bmp, "rb").read()
    off = struct.unpack_from("<I", data, 10)[0]
    w, h = struct.unpack_from("<ii", data, 18)
    bpp = struct.unpack_from("<H", data, 28)[0]
    step, h = bpp // 8, abs(h)
    row = (w * step + 3) & ~3
    out = []
    for y in range(h):
        for x in range(w):
            i = off + y * row + x * step
            b, g, r = data[i], data[i + 1], data[i + 2]
            out.append((r / 255, g / 255, b / 255))
    return out


def hue_mean(hues_w):
    """Moyenne circulaire pondérée de teintes (degrés)."""
    sx = sum(w * math.cos(math.radians(h)) for h, w in hues_w)
    sy = sum(w * math.sin(math.radians(h)) for h, w in hues_w)
    if abs(sx) + abs(sy) < 1e-9:
        return None
    return math.degrees(math.atan2(sy, sx)) % 360


def hexc(h, l, s):
    r, g, b = colorsys.hls_to_rgb((h % 360) / 360, max(0, min(1, l)), max(0, min(1, s)))
    return "%02x%02x%02x" % tuple(round(c * 255) for c in (r, g, b))


def lum(hx):
    def ch(c):
        c = int(c, 16) / 255
        return c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4
    r, g, b = (ch(hx[i:i + 2]) for i in (0, 2, 4))
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def contrast(a, b):
    la, lb = sorted((lum(a), lum(b)), reverse=True)
    return (la + 0.05) / (lb + 0.05)


def main():
    img, out = sys.argv[1], sys.argv[2]
    name = sys.argv[3] if len(sys.argv) > 3 else os.path.splitext(os.path.basename(img))[0]
    px = [colorsys.rgb_to_hls(*p) for p in pixels(img)]  # (h 0..1, l, s)
    dark = [(h * 360, s) for h, l, s in px if l < 0.35 and s > 0.08]
    light = [(h * 360, s) for h, l, s in px if l > 0.65 and s > 0.05]
    vivid = [(h * 360, s * (1 - abs(l - 0.5) * 2)) for h, l, s in px if s > 0.25 and 0.2 < l < 0.85]
    hd = hue_mean(dark) if dark else 220
    hl = hue_mean(light) if light else hd
    sd = min(0.55, sum(s for _, s in dark) / len(dark)) if dark else 0.3
    pal = {
        "base00": hexc(hd, 0.10, sd), "base01": hexc(hd, 0.14, sd * 0.85), "base02": hexc(hd, 0.21, sd * 0.7),
        "base03": hexc(hd, 0.45, sd * 0.35),
        "base04": hexc(hl, 0.72, 0.25), "base05": hexc(hl, 0.88, 0.45), "base06": hexc(hl, 0.92, 0.45),
        "base07": hexc(hl, 0.95, 0.45),
    }
    bg = pal["base00"]
    for key in ("base04", "base05"):
        l = 0.72 if key == "base04" else 0.88
        while contrast(pal[key], bg) < (4.5 if key == "base04" else 10) and l < 0.97:
            l += 0.02; pal[key] = hexc(hl, l, 0.25 if key == "base04" else 0.45)
    notes, chosen = {}, []
    dist = lambda a, b: min(abs(a - b), 360 - abs(a - b))
    for key, target, s, l, note in ROLES:
        # Fenêtre d'attraction : plus étroite pour orange et or (sinon tous deux tirés vers la même teinte d'image)
        window = {"base09": 8, "base0A": 15}.get(key, 22)
        near = [(h, w) for h, w in vivid if dist(h, target) <= window]
        h = target
        if sum(w for _, w in near) > 0.5:
            m = hue_mean(near)
            if m is not None:
                h = m
        # Écart minimal de 20° avec les accents déjà placés (sauf brun, distinct par sa luminosité) :
        # en cas de collision, se placer à 20° du voisin, du côté de sa teinte de référence.
        if key != "base0F":
            for _ in range(8):
                clash = [c for c in chosen if dist(c, h) < 20]
                if not clash:
                    break
                c = clash[0]
                side = 1 if ((target - c + 540) % 360 - 180) >= 0 else -1
                h = (c + 20 * side) % 360
            chosen.append(h % 360)
        c = hexc(h, l, s)
        while contrast(c, bg) < 4.5 and l < 0.9:
            l += 0.02; c = hexc(h, l, s)
        pal[key] = c
        notes[key] = f"{note} (teinte {round(h)}°{' issue de l image' if h != target else ''})"
    lines = [f'# Généré par scripts/palette-from-image.py depuis {os.path.basename(img)} — ne pas éditer à la main.',
             '{', f'  scheme = "{name}"; author = "macos-config (auto)";']
    for i in range(16):
        k = f"base0{i:X}"
        lines.append(f'  {k} = "{pal[k]}";' + (f' # {notes[k]}' if k in notes else ''))
    lines.append('}')
    open(out, "w").write("\n".join(lines) + "\n")
    worst = min(contrast(pal[f"base0{i:X}"], bg) for i in range(8, 16))
    print(f"{out} : fond #{bg} (teinte {round(hd)}°), texte #{pal['base05']}, contraste mini accents {worst:.1f}:1")


if __name__ == "__main__":
    main()
