# OmniWM in this setup — complete reference

OmniWM ([upstream](https://github.com/OmniNull/OmniWM)) is the **only** window manager. It tiles windows,
owns workspaces, trackpad gestures and the Overview. Everything below describes the build and the
settings this repo installs; values marked *default* are OmniWM's own defaults.

## 1. Build: upstream + a small patch series
| Piece | Where |
|---|---|
| Pinned upstream commit | `tools/omniwm/UPSTREAM` |
| Local patches (git `format-patch` series) | `tools/omniwm/patches/0001…0007` |
| Build + sign + install | `tools/omniwm/build-local.sh` (`--check` = patches apply, no build) |
| Signing certificate (once per Mac) | `tools/omniwm/create-signing-cert.sh` |
| Working checkout | `$OMNIWM_SRC` (default `~/src/omniwm`), branch `macos-config`, recreated on every build |

Why a local build: the patches below are not upstream. Why a self-signed certificate: macOS ties the
Accessibility and Screen Recording grants to the code signature; an ad-hoc signature changes on every
build, so permissions would be lost on each rebuild. The certificate pins them (`codesign -dr -` shows
`certificate leaf = H"…"`).

| Patch | What it does | Why |
|---|---|---|
| 0001 | `OverviewHideWorkspaceLabels` default hides the workspace names/numbers on the left of the Overview | cleaner Overview (user choice) |
| 0002 | `OverviewHideSearchBar` default hides the Overview search bar (typing still filters) | idem |
| 0003 | hidden search bar keeps a 44 pt top inset | otherwise the first row sits under the notch band |
| 0004 | parking-edge masks (1 pt windows at both screen edges) show the wallpaper slice instead of black and swallow clicks; swipe captures at Retina 2x; `swipe-geometry` log | black line at the edges; clicks at the edge reached parked windows and switched workspace; soft/dull swipes (bugs B6, B7 in `docs/bugs.md`) |
| 0005 | workspace swipe leaves out Niri columns whose settled frame is clamped to the screen edge | third Niri column drawn over the second during swipes (B8) |
| 0006 | swipe previews use WindowServer-composited snapshots of the visible workspace (`NativeWindowSnapshotCache`) | per-window captures replace Ghostty's blur with an opaque material: washed-out colours during swipes (B7) |
| 0007 | `swipe-snapshot` log: which windows used a native snapshot vs the live capture | verifying 0006 |

Tests added by the patches (run targeted only, never the full suite on a machine in use — it froze the
Mac once): `swift test --filter "WorkspaceSwipeNiriClampTests|ParkingEdgeMaskTests|WorkspaceSwipePreviewTests|WorkspaceSwipePreviewWarmupTests"`.

**Changing a patch:** `tools/omniwm/build-local.sh --check` → edit/commit in `$OMNIWM_SRC` on branch
`macos-config` → `git -C $OMNIWM_SRC format-patch -o <repo>/tools/omniwm/patches $(cat tools/omniwm/UPSTREAM)..HEAD`
(delete the old files first) → `build-local.sh`. **Updating upstream:** put the new commit in `UPSTREAM`,
run `--check`; if a patch no longer applies, rebase the branch and re-export.

Fixes that existed in earlier local builds but are **not** in this series (re-port only with a test):
diagonal 3-finger start waits for its direction; System Settings / auth dialogs keep focus against
focus-follows-mouse; Secure Input explanation panel suppressed; key-window re-assert after same-app
focus hand-offs; Dwindle drop near an edge inserts instead of swapping; notch full-height option
(`gaps.fullHeightWhenMenuBarHidden` is still in `settings.toml` but is ignored by this build).
Their history: `docs/bugs.md`.

## 2. Configuration files
| File | Role |
|---|---|
| `~/.config/omniwm/settings.toml` ↔ `tools/omniwm/config/settings.toml` | the full OmniWM config (captured copy) |
| `tools/omniwm/apply-registry.py` | enforces the parts this repo owns: hotkeys, gestures, workspace names, gaps, layouts, Overview look, and `singleWindowFit` computed from the main screen. Preview by default, `--write` with OmniWM **quit** (it rewrites the file otherwise). `scripts/theme-sync.sh` runs it on every wallpaper change, so the registry must always describe the wanted state (`scripts/check.sh` tests that it changes nothing in the captured file). |
| `defaults write com.barut.OmniWM …` | the two patch options (0001, 0002); set by `scripts/macos-defaults.sh` |

## 3. Workspaces and layouts
| # | Name | Layout | Apps assigned by rule |
|---|---|---|---|
| 1 | Focus | **Dwindle** (classic tiling) | Ghostty |
| 2 | Web | **Niri** | Safari |
| 3 | Messages | Niri | Discord |
| 4 | Atelier | Niri | Finder |
| 5–9 | 5, ❤️, 🚀, 8, 9 | Niri | — |

- **Dwindle** (W1): binary splits. One window fills the work area; each new window splits the focused
  tile. Nothing scrolls; 3-finger horizontal swipes do nothing there.
- **Niri** (W2–9): windows live in **columns on an endless horizontal strip**. 2 columns are visible
  (`visibleContainerCount = 2`), each half the width (`defaultContainerPrimarySpan = 0.5`, presets ⅓ ½ ⅔).
  More windows do not shrink the others: new columns open to the right and you scroll to them. Columns
  scrolled out of view are *parked* (see §8).
- A lone window, in both layouts, gets `singleWindowFit` = screen minus the 8 pt outer gaps (computed per
  Mac by `apply-registry.py`), so no window ever touches a screen edge.
- Gaps: 8 pt between windows and at every screen edge.
- Each workspace keeps its own window order and layout state; switching never reorganises another one.
- **Empty workspaces are hidden** (`workspaceBar.hideEmptyWorkspaces = true`): swipes, next/previous and
  the Overview skip them; the active one is always shown. A workspace reappears as soon as a window lands.
- App rules also **float** System Settings, SecurityAgent and the authentication dialogs (they keep their
  own size) and list a few apps without assignment (they open on the current workspace).
- `Control+Option+G` toggles Dwindle ↔ Niri on the current workspace (runtime only; the registry restores
  the layouts above on the next apply).

## 4. Gestures (trackpad)
| Gesture | Action | Owner |
|---|---|---|
| 3 fingers **up / down** | previous / next (non-empty) workspace; the content follows the fingers vertically, release past the middle or flick to commit | OmniWM |
| 3 fingers **left / right** | scroll the Niri columns of the current workspace (snaps to columns) | OmniWM (`scrollEnabled`, `trackpadScrollStyle = snap`) |
| 4 fingers **up** | open the Overview | OmniWM |
| 2 fingers | normal scrolling (natural direction) | macOS |

How the axes never conflict: both 3-finger gestures use the same finger count, so OmniWM decides on the
**dominant axis** after a few points of travel (`TrackpadGestureIntent.swift`); when column scrolling is on,
the workspace swipe automatically takes the other axis (vertical). A diagonal start can be dropped (the
fix for that is not in this build, see §1).

macOS must not see these gestures, otherwise Mission Control / Spaces animate behind OmniWM's:
`scripts/macos-defaults.sh` turns off the macOS 3- and 4-finger swipes (built-in and Bluetooth trackpad
domains + the per-host keys) and the Mission Control / App Exposé trackpad gestures
(`com.apple.dock showMissionControlGestureEnabled = 0`).

## 5. Overview (4 fingers up, or Hyper+O)
OmniWM's stock "Niri overview": all non-empty workspaces stacked vertically, the current one as a
horizontal strip of its windows (the "T" layout), live window previews, wallpaper behind (transparent
backdrop `overview.backdrop.alpha = 0`), `zoom = 0.5`, no labels and no search bar (patches 0001–0002).
Click a window to focus it (and its workspace); drag a window onto another workspace to move it; the empty
area at the bottom (+) creates a workspace. Previews come from ScreenCaptureKit, so OmniWM needs **Screen
Recording**; grey previews mean that permission is missing or the app is hidden (B10).

## 6. Mouse: focus, drag and drop, swap
- **Focus follows the mouse** (`focus.followsMouse = true`, no raise): hovering a window focuses it.
  Floating System Settings / auth dialogs should keep focus while open (that guard is not in this build).
- **Move / swap with the mouse**: drag a window by its title bar, or anywhere with **Option + drag**.
  Dropping on another tile **swaps** the two (upstream behaviour). The "drop on an edge inserts beside"
  and Niri stack/new-column drops of earlier local builds are not in this build (§1).
- Keyboard equivalents: §7. `Control+Option+T` floats/unfloats the focused window.

## 7. Keyboard (OmniWM)
Bindings use **QWERTY key positions** (OmniWM binds by key code): on the French AZERTY keyboard the key
printed W sends Z, A sends Q, Q sends A. The full AZERTY table, with every tool, is `docs/shortcuts.md`.
Hyper = Control+Option+Command. Option alone is never bound (it types `{ } [ ] | @` on AZERTY).

| Keys | Action |
|---|---|
| Control+1…9 / Control+Shift+1…9 | go to workspace N / send the window there |
| Control+Option+Tab | previous workspace (back and forth) |
| Control+←/→, Hyper+↑/↓ | focus left/right/up/down |
| Control+Shift+←/→, Hyper+Shift+↑/↓ | move the window |
| Control+Option+Shift+←/→ | move the column (Niri) |
| Control+Option+Shift+↑/↓ (PgUp/PgDn = column) | send window / column to the workspace above/below |
| Control+Option+1…9, Home/End | focus column N, move column to first/last |
| Control+Option+F | fullscreen |
| Control+Option+R / E / S | balance sizes / toggle split orientation / swap split (Dwindle) |
| Control+Option+(W key) / (Q key) | grow / shrink the focused window |
| Control+Option+(A key) / D / (Z key) / C | preselect left / right / down / clear (Dwindle) |
| Control+Option+G | toggle Dwindle ↔ Niri on this workspace |
| Control+Option+T / X / M | float toggle / rescue off-screen windows / menu anywhere |
| Hyper+O / Hyper+Space / Hyper+Return | Overview / command palette / quake terminal |

## 8. How OmniWM moves windows (and what that implies)
- macOS has no public API to move another app's windows except **Accessibility (AX)**: OmniWM asks each
  app's process to move/resize its window. That is why animations of real windows are limited by the
  apps (heavy apps update slowly) and why OmniWM needs Accessibility.
- **Workspaces are not macOS Spaces.** Windows of inactive workspaces (and Niri columns scrolled away)
  are *parked*: moved so that only 1 pt stays on screen at the right edge (macOS refuses fully off-screen
  windows). OmniWM's 1 pt `ParkingEdgeMask` hides that point (patch 0004); their shadow would still darken
  the 8 pt right gap, so Hammerspoon's `margin-veil.lua` covers the gap with the matching wallpaper slice
  and swallows clicks there (`docs/bugs.md` B6).
- **Swipes and the Overview animate captures, not windows**: at the first trackpad contact OmniWM
  prepares images of the source and destination workspaces and animates those layers in its own panel
  (smooth regardless of how slowly apps answer AX); the real windows are placed once, at the end. Patch 0006 makes
  the visible workspace's images WindowServer-composited (identical to the screen, keeps Ghostty's blur);
  a destination workspace uses its last native snapshot (taken when you last left it) or a live capture.
- Focus is given with private SkyLight calls (same technique as yabai): front process + key-window
  event records (`PrivateAPIs.swift`).

## 9. Interaction with other components
| Component | Interaction |
|---|---|
| Hammerspoon `ws-hide.lua` | subscribes to OmniWM IPC (`omniwmctl subscribe`); after a workspace switch it focuses the window under the pointer (or the first one) when OmniWM could not; feeds `margin-veil`. It no longer hides apps despite its name. |
| Hammerspoon `margin-veil.lua` | wallpaper strip over the right gap (above parked windows, below OmniWM's panels) |
| Hammerspoon `ax-guard.lua` | restarts OmniWM and Neru when an Accessibility grant changes (revoking it used to freeze input) |
| Ghostty | tiled on Focus; its blur/transparency is why patch 0006 exists |
| Safari / Discord / Finder | assigned by rule to Web / Messages / Atelier, tiled |
| Neru | keyboard hints/scrolling; independent; also needs Accessibility |
| macOS | Stage Manager off (`com.apple.WindowManager GloballyEnabled = 0`): with it on, workspace switches showed empty screens |
| theme | `scripts/theme-sync.sh` recolours OmniWM's border settings and re-applies the registry on wallpaper change |

## 10. Diagnostics
- `scripts/doctor.sh` — OmniWM signed with the stable certificate, running, IPC answering, Niri present,
  registry = settings, macOS gesture settings.
- `omniwmctl query workspaces|windows`, `omniwmctl command switch-workspace N`.
- Logs: `/usr/bin/log stream --predicate 'subsystem == "com.barut.OmniWM"'` (categories `swipe-geometry`,
  `swipe-snapshot`). Under zsh, plain `log` is a shell builtin: always use `/usr/bin/log`.
- Emergency: `scripts/emergency-stop.sh` / `emergency-start.sh`, `docs/recovery.md`.
