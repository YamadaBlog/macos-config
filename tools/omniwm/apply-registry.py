#!/usr/bin/env python3
"""Applique le registre de raccourcis AZERTY du poste à settings.toml d'OmniWM.

Usage : python3 -I apply-registry.py <settings.toml> [--write]
Sans --write : affiche les changements prévus, n'écrit rien.
OmniWM doit être quitté avant --write (sinon il réécrit le fichier).

Règles :
- Hyper = Control+Option+Command ; Shift ajouté = transfert/déplacement.
- Tout raccourci « Option+… » sans Control ni Command est désassigné : sur AZERTY
  ces combinaisons tapent { } [ ] | @ ~ etc.
- IPC activé (requis par Hammerspoon / omniwmctl).
- Bureaux 1-4 étiquetés Focus / Web / Messages / Atelier via displayName (name reste numérique).
"""
import re
import sys

H = "Hyper+"  # forme normalisée écrite par OmniWM quand hyperKeyModifiers = Control+Option+Command
# OmniWM 0.7.6 lie les touches par POSITION (codes ANSI/QWERTY), pas par caractère.
# Touche imprimée W sur AZERTY = position Z en QWERTY. E, D, T, O, F : même position.
AZ_W = "Z"
HS = "Hyper+Shift+"
REGISTRY = {
    # Bureaux : 2 touches main gauche (choix utilisateur 2026-10-08 : Hyper jugé trop complexe).
    # Ctrl+chiffre : libre dans macOS (raccourcis « bureau N » non activés) et dans les terminaux.
    "switchWorkspace.0": "Control+1", "switchWorkspace.1": "Control+2",
    "switchWorkspace.2": "Control+3", "switchWorkspace.3": "Control+4",
    "moveToWorkspace.0": "Control+Shift+1", "moveToWorkspace.1": "Control+Shift+2",
    "moveToWorkspace.2": "Control+Shift+3", "moveToWorkspace.3": "Control+Shift+4",
    # Fenêtre précédente : Option+Tab ne tape aucun caractère (exception à la règle « pas d'Option seul »).
    "focusPrevious": "Option+Tab",
    # Gauche/droite entre fenêtres (colonnes) : Ctrl+flèche ; déplacer : Ctrl+Shift+flèche.
    # Reprennent les raccourcis macOS « espace précédent/suivant » (symbolichotkeys 79-82, désactivés : un seul espace).
    "focus.left": "Control+Left Arrow", "focus.right": "Control+Right Arrow",
    "focus.up": H + "Up Arrow", "focus.down": H + "Down Arrow",
    "move.left": "Control+Shift+Left Arrow", "move.right": "Control+Shift+Right Arrow",
    "move.up": HS + "Up Arrow", "move.down": HS + "Down Arrow",
    "toggleOverview": H + "O",
    "openCommandPalette": H + "Space",
    "toggleQuakeTerminal": H + "Return",
    # Dwindle controls (2026-10-09): Ctrl+Option + left-hand letter. Names are QWERTY POSITIONS:
    # printed AZERTY W = "Z", Q = "A", A = "Q", Z = "W" (E R S D F G T X C are the same).
    "toggleFullscreen": "Control+Option+F",            # plein écran temporaire
    "expandContainerToAvailablePrimarySpan": "Unassigned", "resetWindowSecondarySpan": "Unassigned",
    "balanceSizes": "Control+Option+R",                # parts égales
    "toggleSplit": "Control+Option+E",                 # côte à côte <-> empilé
    "swapSplit": "Control+Option+S",                   # échanger les deux moitiés
    "resizeFocusedWindow.grow": "Control+Option+Z", "resizeFocusedWindow.shrink": "Control+Option+A",
    "toggleFocusedWindowFloating": "Control+Option+T", # flottante <-> pavée
    "toggleWorkspaceLayout": "Control+Option+G",       # Dwindle <-> Niri sur ce bureau
    "rescueOffscreenWindows": "Control+Option+X",      # ramener les fenêtres hors écran
    "preselect.left": "Control+Option+Q", "preselect.right": "Control+Option+D",
    "preselect.down": "Control+Option+W", "preselectClear": "Control+Option+C",
}
NAMES = {"1": "Focus", "2": "Web", "3": "Messages", "4": "Atelier"}
INVERSE = {v: k for k, v in NAMES.items()}
GENERAL = {"ipcEnabled": "true", "updateChecksEnabled": "false",  # local build with the Accessibility fix: no auto-update
           "hyperKeyModifiers": '"Control+Option+Command"'}
# Apparence : bordure et barre DÉSACTIVÉES par choix de l'utilisateur (2026-10-08) ; réglages conservés
# pour une réactivation éventuelle (passer enabled à "true"). Accent #91baff = Ghostty palette 4.
SECTIONS = {
    "[borders]": {"enabled": "false", "width": "2.0"},
    "[borders.color]": {"red": "0.5686", "green": "0.7294", "blue": "1.0", "alpha": "0.85"},
    # Gestes : 3 doigts horizontal = colonnes ; 4 doigts horizontal = bureaux (remplace le geste
    # macOS des espaces, sans effet avec un seul espace ; macOS TrackpadFourFingerHorizSwipeGesture = 0).
    "[gestures]": {"fingerCount": "3", "scrollEnabled": "true", "workspaceSwipeEnabled": "true",
                   "workspaceSwipeAxis": '"horizontal"', "workspaceSwipeFingerCount": "4"},
    # Disposition Dwindle partout : 1 fenêtre = tout l'écran, l'espace se divise à chaque ouverture.
    "[general]": {"defaultLayoutType": '"dwindle"'},
    # Dwindle, window alone: "fill" ignores the outer gaps (window touches the edges). Exact size =
    # 1728-16 x 1117-40-8, i.e. the working area: no window may touch a screen edge, on any workspace.
    "[dwindle]": {"singleWindowFit": '"1712x1069"'},
    # Niri (si réactivé sur un bureau) : 2 colonnes visibles, colonnes à la moitié.
    "[niri]": {"visibleContainerCount": "2", "defaultContainerPrimarySpan": "0.5", "edgeGaps": "false",
               # Fenêtre seule : taille fixe = écran intégré 1728x1117 (Retina 2x) moins les marges
               # (1728-16 x 1117-40-8). À adapter si l'écran ou sa résolution changent.
               "singleWindowFit": '"1712x1069"'},
    "[gaps]": {"size": "8.0"},
    "[gaps.outer]": {"top": "40.0", "bottom": "8.0", "left": "8.0", "right": "8.0"},
    "[workspaceBar]": {"enabled": "false", "transparentBackground": "true", "showLabels": "true",
                       "hideEmptyWorkspaces": "true", "deduplicateAppIcons": "true",
                       "reserveLayoutSpace": "false"},  # aucun espace réservé (barre désactivée ; si réactivée, passer à "true" pour ne pas chevaucher les fenêtres)
}


def conflicts_with_typing(binding):
    parts = binding.split("+")
    if binding == "Option+Tab":
        return False
    return "Option" in parts and "Control" not in parts and "Command" not in parts and "Hyper" not in parts


def palette_border():
    """Couleur de bordure = base0D (accent) de la palette Stylix (~/.config/stylix/palette.json), si présente."""
    import json, os
    f = os.path.expanduser("~/.config/stylix/palette.json")
    if not os.path.exists(f):
        return
    h = json.load(open(f))["base0D"]
    r, g, b = (round(int(h[i:i + 2], 16) / 255, 4) for i in (0, 2, 4))
    SECTIONS["[borders.color]"] = {"red": str(r), "green": str(g), "blue": str(b), "alpha": "0.85"}


def main():
    palette_border()
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    path, write = sys.argv[1], "--write" in sys.argv[2:]
    lines = open(path, encoding="utf-8").read().split("\n")
    changes, inserts, section = [], [], None
    # Repère les blocs [[hotkeys]] : binding puis id (ordre observé en 0.7.6)
    for i, line in enumerate(lines):
        if line.startswith("["):
            section = line.strip()
        if section in SECTIONS:
            m = re.match(r'^(\w+) = (.*)$', line)
            want = SECTIONS[section].get(m.group(1)) if m else None
            if want is not None and m.group(2) != want:
                changes.append((i, f"{m.group(1)} = {want}"))
        if section == "[general]":
            m = re.match(r'^(\w+) = (.*)$', line)
            if m and m.group(1) in GENERAL and m.group(2) != GENERAL[m.group(1)]:
                changes.append((i, f"{m.group(1)} = {GENERAL[m.group(1)]}"))
        if section == "[[workspaces]]":
            # OmniWM 0.7.6 ignore un bureau dont « name » n'est pas numérique :
            # le nom reste le chiffre, l'étiquette va dans displayName.
            m = re.match(r'^name = "(.*)"$', line)
            if m:
                num = INVERSE.get(m.group(1), m.group(1))
                if num != m.group(1):
                    changes.append((i, f'name = "{num}"'))
                if num in NAMES:
                    label = f'displayName = "{NAMES[num]}"'
                    # displayName précède id dans le bloc (ordre écrit par OmniWM)
                    j = i
                    while j > 0 and not lines[j].startswith("[[workspaces]]"):
                        j -= 1
                    block = lines[j + 1:i]
                    cur = [k for k, l in enumerate(block, j + 1) if l.startswith("displayName = ")]
                    if cur and lines[cur[0]] != label:
                        changes.append((cur[0], label))
                    elif not cur:
                        inserts.append((j + 1, label))
        if section == "[[hotkeys]]" and line.startswith("binding = "):
            nxt = lines[i + 1] if i + 1 < len(lines) else ""
            m = re.match(r'^id = "(.*)"$', nxt)
            if not m:
                continue
            hid, cur = m.group(1), line[len('binding = "'):-1]
            want = REGISTRY.get(hid)
            if want is None and conflicts_with_typing(cur):
                want = "Unassigned"
            if want and want != cur:
                changes.append((i, f'binding = "{want}"'))
    # Un raccourci du registre ne doit pas déjà servir à une autre action
    used = {}
    for i, line in enumerate(lines):
        if line.startswith("binding = ") and i + 1 < len(lines):
            new = dict(changes).get(i, line)
            b = new[len('binding = "'):-1]
            if b != "Unassigned":
                used.setdefault(b, []).append(lines[i + 1])
    dup = {b: ids for b, ids in used.items() if len(ids) > 1}
    for i, new in changes:
        ctx = lines[i + 1].strip() if lines[i].startswith("binding") else ""
        print(f"{i + 1:5d}: {lines[i].strip()}  ->  {new}  {ctx}")
    for i, new in inserts:
        print(f"{i + 1:5d}: (insertion)  ->  {new}")
    print(f"{len(changes) + len(inserts)} changement(s)")
    if dup:
        print("DOUBLONS :", dup)
        sys.exit(1)
    if write and (changes or inserts):
        for i, new in changes:
            lines[i] = new
        for i, new in sorted(inserts, reverse=True):
            lines.insert(i, new)
        open(path, "w", encoding="utf-8").write("\n".join(lines))
        print("écrit :", path)


if __name__ == "__main__":
    main()
