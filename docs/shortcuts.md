# Shortcuts and gestures

Single registry of every keyboard shortcut and trackpad gesture. Designed for a French **AZERTY** keyboard:
keys below are the letters **printed on the keyboard**. Daily use needs at most two left-hand keys or the trackpad.

## Windows and workspaces (OmniWM)
Layouts: workspace 1 (Focus) = Dwindle; 2 (Web), 3 (Messages), 4 (Atelier) and 5–9 = Niri (scrolling columns, 2 visible).
Empty workspaces are skipped. Details: `docs/omniwm.md`.

| Keys | Effect |
|---|---|
| **Ctrl+1…9** | go to workspace 1–9 |
| **Ctrl+Shift+1…9** | send the active window to that workspace |
| **Ctrl+← → ↑ ↓** | focus the neighbouring window |
| **Ctrl+Shift+← → ↑ ↓** | move the window (Dwindle: swap with the neighbour; Niri: ←/→ into the next column, ↑/↓ inside the column) |
| **Option+Tab** | previous window (also across workspaces) |
| **Ctrl+Option+Tab** | previous workspace |
| **Ctrl+Option+W / A** | grow / shrink the active window |
| **Ctrl+Option+R** | balance sizes |
| **Ctrl+Option+F** | temporary fullscreen (same keys to exit) |
| **Ctrl+Option+E** | toggle split orientation (side by side ↔ stacked) |
| **Ctrl+Option+S** | swap the two halves |
| **Ctrl+Option+Q / D / Z** | the **next** window opens left / right / below |
| **Ctrl+Option+C** | cancel that choice |
| **Ctrl+Option+T** | float ↔ tile the window |
| **Ctrl+Option+G** | toggle this workspace between Dwindle and Niri |
| **Ctrl+Option+X** | bring back off-screen windows |
| **Drag a window by its title bar** (or Option+drag anywhere in it) | drop near an **edge** of another window: inserted on that side, the rest reflows; drop in its **center**: the two swap |
| **Option+drag an edge** | resize with the mouse |
| **Hyper+Space** | OmniWM command palette (every action, even unbound ones) |
| **Hyper+O** | Overview |
| **Hyper+Return** | Quake terminal |

**Hyper = Ctrl + Option + Cmd.** No Caps Lock remap (`systemHyperTrigger = "None"`).
AZERTY rule: no **Option alone (+ Shift)** shortcut — those combinations type `{ } [ ] | @ ~ € …`.

## Other tools
| Keys | Owner | Effect |
|---|---|---|
| Hyper+N / G / S | Neru | hints / grid / scroll mode |
| Esc | Neru | leave a mode |
| Hyper+P | Hammerspoon | pick a context (workspace + resources) |
| Cmd+E | Hammerspoon | bring Finder to front (opens ~ if no window) |
| Cmd+Space | Raycast | launcher, clipboard history |
| Cmd+Option+Space | macOS | Finder search |
| Option+Space | typing | non-breaking space |
| Ctrl-R (terminal) | Atuin | shell history |

Full OmniWM list: the `[[hotkeys]]` entries of `tools/omniwm/config/settings.toml`; the bindings this repo owns are in `tools/omniwm/apply-registry.py`.

## Trackpad
| Gesture | Owner | Effect |
|---|---|---|
| 2 fingers | macOS / apps | content scrolling |
| **3 fingers up / down** | OmniWM | previous / next workspace |
| **3 fingers left / right** | OmniWM | scroll Niri columns (Niri workspaces only) |
| **4 fingers up** | OmniWM | Overview (also Hyper+O); click a window to jump to it |

macOS 3- and 4-finger swipes and the Mission Control gesture are disabled in `home-manager/macos.nix`.

## Technical notes
- **OmniWM binds physical key positions (QWERTY names).** In `settings.toml`, printed AZERTY **W** is `Z`,
  **A** is `Q`, **Q** is `A`, **Z** is `W`, **M** is `Semicolon`; E R T D F G S X C N O P are identical.
  `tools/omniwm/apply-registry.py` holds the mapping and is the source of truth (the theme script reapplies it).
  Neru and Hammerspoon read the **characters** of the active layout instead.
- OmniWM writes Hyper shortcuts as `Hyper+…` because `hyperKeyModifiers = "Control+Option+Command"`.
- The macOS "previous/next Space" shortcuts (Ctrl+←/→, symbolichotkeys 79–82) are disabled so OmniWM can use them.
  Minor conflict: in Cocoa text fields Ctrl+←/→ (line start/end) is taken; Cmd+←/→ does the same.

## Adding a shortcut
1. Check this registry and the `[[hotkeys]]` of `tools/omniwm/config/settings.toml` (no duplicates).
2. Never Option alone; prefer Ctrl+Option + a free left-hand letter.
3. For OmniWM, use the QWERTY position name (see above) and add it to `apply-registry.py`.
4. Capture (`scripts/capture.sh`) and update this registry.
