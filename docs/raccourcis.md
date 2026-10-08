# Shortcut registry (French AZERTY keyboard)

**Daily use: 2 left-hand keys or the trackpad.** Keys below are the letters **printed on the AZERTY keyboard**.

## Windows and workspaces (OmniWM, Dwindle layout)
| Keys | Effect |
|---|---|
| **Ctrl+1…9** | go to workspace 1–9 (1 Focus · 2 Web · 3 Messages · 4 Atelier) |
| **Ctrl+Shift+1…9** | send the active window to that workspace |
| **Ctrl+← → / Hyper+↑ ↓** | focus the neighbouring window |
| **Ctrl+Shift+← → / Hyper+Shift+↑ ↓** | move the window |
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
| **Ctrl+Option+G** | toggle this workspace between Dwindle and Niri (scrolling) |
| **Ctrl+Option+X** | bring back off-screen windows |
| **Option+drag / Option+drag an edge** | move / resize with the mouse |
| **Hyper+Space** | OmniWM command palette (every action, even unbound ones) |
| **Hyper+O** | Overview |
| **Hyper+Return** | Quake terminal |

**Hyper = Ctrl + Option + Cmd** (Option = Alt). No Caps Lock remap (`systemHyperTrigger = "None"`).
AZERTY rule: no **Option alone (+ Shift)** shortcut — those combinations type `{ } [ ] | @ ~ € …`.

## Other tools
| Keys | Owner | Effect |
|---|---|---|
| Hyper+N / G / S | Neru | hints / grid / scroll mode |
| Esc | Neru | leave a mode |
| Hyper+P | Hammerspoon | pick a context (workspace + resources) |
| Cmd+E | Hammerspoon | bring Finder to front (opens ~ if no window) |
| Cmd+Space | Raycast | launcher, quicklinks, clipboard |
| Cmd+Option+Space | macOS | Finder search |
| Option+Space | typing | non-breaking space |
| `;bjr` | Raycast | e-mail greeting snippet |
| Ctrl-R (terminal) | Atuin | shell history |

Full OmniWM list: `docs/generated/omniwm-hotkeys.tsv` (regenerated on each capture).

## Trackpad
| Gesture | Owner |
|---|---|
| 2 fingers | content scrolling (macOS/apps) |
| 3 fingers horizontal | OmniWM (`gestures.fingerCount = 3`) |
| 4 fingers horizontal | OmniWM: previous / next workspace |
| 3 fingers vertical, pinch | macOS: Mission Control / App Exposé / Launchpad |

## Technical notes
- **OmniWM binds by physical key position (QWERTY names).** In `settings.toml`, printed AZERTY **W** is `Z`,
  **A** is `Q`, **Q** is `A`, **Z** is `W`, **M** is `Semicolon`; E R T D F G S X C N O P are identical.
  `tools/omniwm/apply-registry.py` holds the mapping and is the source of truth (the theme script reapplies it).
- OmniWM writes Hyper shortcuts as `Hyper+…` because `hyperKeyModifiers = "Control+Option+Command"`.
- macOS "previous/next Space" shortcuts (Ctrl+←/→, symbolichotkeys 79–82) are disabled for OmniWM.
  Minor known conflict: in Cocoa text fields Ctrl+←/→ (line start/end) is taken; Cmd+←/→ does the same.

## Adding a shortcut
1. Check this table and `docs/generated/omniwm-hotkeys.tsv` (no duplicates).
2. Never Option alone; prefer Ctrl+Option + a free left-hand letter.
3. For OmniWM, use the QWERTY position name (see above), and add it to `apply-registry.py`.
4. Capture (`scripts/capture.sh`) and update this table.
