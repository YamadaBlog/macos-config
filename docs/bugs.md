# Bug catalogue (what broke, why, and how we know it stays fixed)

One entry per real problem met on this setup. **Cause** is marked *established* only when a commit,
measurement or log proved it; otherwise *hypothesis*. **Status** says whether the fix is active in the
current build (OmniWM = `tools/omniwm/UPSTREAM` + `tools/omniwm/patches/`). Fixes marked "not in the current build" existed in earlier local OmniWM builds; re-port them as a
patch with a test if needed.

Before changing anything listed here, read the entry and keep its verification passing.

---

### B1 — Lags during transitions and window moves
- **Symptom:** everything felt slow when switching and moving windows (2026-10-15).
- **Cause (established):** not the window manager: a background campaign ran 18–32 Python workers (load
  23–39). Sample: OmniWM 0.01 s CPU, Hammerspoon 0.01 s, WindowServer 3.7 s over 30 s.
- **Fix:** workers reniced to 15. Rule: measure (`top -o cpu`, `sample`) before blaming OmniWM.
- **Related, established:** real-window animations are driven through Accessibility, so heavy apps only
  get a few frames; swipes therefore animate captures (B7). An old ws-hide stall of ~6 s (isHidden on ~100
  apps) was removed; theme-auto went from 3.3 s to 33 ms per wake.
- **Verify:** `scripts/doctor.sh`; `top -o cpu` during a swipe.

### B2 — A simple click started a window drag (Niri title-bar move)
- **Cause (established):** the local title-bar move started without a travel threshold and from the whole window.
- **Fix:** 12 pt travel threshold, top 30 pt only, one press state machine.
- **Status:** **not in the current build** (the whole local title-bar-move feature was dropped on 2026-10-15
  when returning to upstream behaviour). Tests existed: `NiriTitleBarPressTests`.

### B3 — Regression: title-bar drags never moved windows
- **Cause (established):** title band computed in the wrong coordinate space (fixed to AppKit coordinates, top = maxY).
- **Status:** not in the current build (same feature as B2).

### B4 — Swap instead of insert on drop (Dwindle)
- **Fix (earlier builds):** drop near a tile edge inserts beside it, centre swaps; aim with the window centre;
  one relayout without a correction jump. Proposed upstream as issue #838.
- **Status:** **not in the current build**: drops swap (upstream behaviour).

### B5 — Focus: window focused but not key (grey traffic lights), Safari unresponsive
- **Symptom:** after a focus change between two windows of the same app, the window looked inactive (grey
  buttons) and clicks were lost.
- **Fix (earlier build):** re-assert the key window after clicks and same-app hand-offs. **Not in the current build.**
- **Safari after a workspace switch (2026-10-09), established:** the Safari window had become *floating*,
  and ws-hide only refocused tiled windows. Fix: app rules force `layout = "tile"` for Safari/Ghostty/
  Discord/Finder, ws-hide also considers floating windows. Verified 8/8 manual switches.
- **Fixed — pointer on a window that stays inactive (2026-10-16, established by `focus-trace`):** OmniWM's
  native-focus record (`nativeManagedFocusToken`) is not updated by same-app hand-offs (hover from one Ghostty
  window to another), so hovering back onto the window it still named was skipped as "already focused" while
  macOS focused another window. Fix (patch "Focus follows mouse: verify macOS focus…"): when the record names
  the hovered window, check macOS (frontmost app + AX focused window) once per pointer entry; refocus if the
  same app focuses another window. Verify: `/usr/bin/log stream --predicate 'category == "focus-trace"'` shows
  "native focus diverged: refocusing" instead of the window staying inactive.
- **Fixed — fast pointer moves leave the window under the pointer unfocused (2026-10-16, measured):** a
  pointer driver (fast moves between window centres, stop, compare window under pointer / macOS AX focus /
  OmniWM focus) gave 8/15 mismatches with yesterday-morning's build and 10/15 with the current one: not a
  regression but a debounce without trailing edge (a move inside the 0.1 s debounce was dropped and never
  retried), hit far more often with Niri's narrow columns. Fix: one pending re-evaluation at debounce expiry
  with the latest mouse sample. After: 0/15 (W1), 0/10 (Niri W2), 1/20 on a longer W1 run; slow moves 0/5.
- **Mitigated at the source — windows drawn inactive while focused / two drawn active (2026-10-16):** caught
  live: macOS key+main, OmniWM focus and pointer all on one Ghostty window, every window drawn grey. Only the
  focus-without-raise path switches windows of one app with the private activate/deactivate records, which act
  on the app's current key window rather than the addressed one; an interrupted or reordered pair leaves the
  appearance wrong. `focus.raiseOnMouseFocus = true` (registry) makes hover focus use the normal one-step path;
  tiled windows never overlap, and OmniWM still avoids covering floating windows. Verify: the watchdog that
  compares coloured traffic lights with AX focus reports no mismatch.
- **Investigation notes (before the raise fix):** 4 Ghostty windows showed
  coloured traffic lights while AX reported a single main/focused window, so the visual state lied about
  the real focus. Measured facts: the SkyLight "same-app activation" record (type 0x0D, state 1/2) acts on the
  app's *current* key window whatever window id it carries; the key-window records (0x01/0x02) are routed by
  WindowServer and interact with focus-follows-mouse. A patch that sent the deactivation record to every other
  window of the app did **not** clear a stale window (reverted). Cause **not established**; next tests:
  (1) a day with `focus.followsMouse = false` to see whether same-app hover hand-offs create the stale windows,
  (2) re-assert the key window through AX after each hand-off (the earlier key-window reconcile).
  Measuring tools: count windows whose traffic-light area is coloured (screen capture of each window's top-left
  corner) and compare with `AXFocusedWindow` of the app.
- Safari ignoring its first clicks after a switch is probably the same family (window not key while it looks
  it, or the reverse).

### B6 — Black strip / black line / "transparent column" at the screen edges
| Step | Symptom | Cause (established) | Fix |
|---|---|---|---|
| a | 8 pt black bar on the right | the wallpaper source file was deleted; margin-veil drew its dark fallback | veil falls back to `wallpapers/actuel.png` |
| b | clicking the right edge switched workspace | veil and OmniWM's 1 pt `ParkingEdgeMask` were click-through, the click reached a parked window | veil swallows clicks; mask swallows clicks (patch 0004) |
| c | veil hidden on W1 and on Niri workspaces | Ghostty overshoots the gap by 1–2 pt (character grid); OmniWM reports an off-screen Niri column at its layout slot | only intrusions deeper than half the gap count, checked against the real window frame |
| d | thin black line on both edges | `ParkingEdgeMask` was painted opaque black | mask shows the wallpaper slice (patch 0004) |
| e | "transparent column" over swipes / Niri scrolling | veil raised to status level painted over OmniWM's panels | veil back to normal+1 level |
- Background: OmniWM parks inactive windows 1 pt inside the right edge (macOS refuses fully off-screen
  windows); hiding their apps instead made swipes "pop" (B9). Rejected: gap 0 (user rule: no window
  touches an edge), corner parking (macOS pulls the title bar back on screen).
- Screenshots do **not** show OmniWM's own surfaces (masks, swipe panel): judge edges by eye or photo.
- **Verify:** `tools/hammerspoon/check-margin-veil.sh --cycle` (in `scripts/verify.sh` and `doctor.sh`);
  OmniWM `ParkingEdgeMaskTests`.

### B7 — Colours, transparency and sharpness lost during workspace swipes
- **Low resolution (established):** captures were capped at 1x on a 2x display. Fix: backing scale
  (patch 0004); capture-cache test aligned with the real 512 MB budget (`WorkspaceSwipePreviewWarmupTests`).
- **Washed-out Ghostty (established by measurement):** same window, mean sRGB on screen (0.192, 0.116,
  0.200) vs per-window ScreenCaptureKit capture (0.225, 0.154, 0.234); colour space (P3/sRGB) and alpha
  ruled out; a display capture with only wallpaper + window is identical to the screen. Cause: a window
  captured alone (`desktopIndependentWindow`) gets an opaque material instead of its live backdrop blur.
- **Fix:** patch 0006 — WindowServer-composited snapshots of the visible workspace (first trackpad contact,
  0.6 s after a swipe lands), used when the window size is unchanged; patch 0007 logs the choice.
- **Limit:** a destination workspace shows its last snapshot (content frozen < 0.5 s).
- **Verify:** by eye during a swipe; `/usr/bin/log stream --predicate 'subsystem == "com.barut.OmniWM" AND category == "swipe-snapshot"'`.

### B8 — Third Niri column drawn over the second during a swipe
- **Cause (established):** an off-screen column's *settled* frame is shifted to the screen edge and clamped
  on screen (`settledRenderedContainerRect`), landing on the last visible column (x=1049 over x=1041).
- **Fix:** patch 0005 leaves out items that both overlap another item by >50 % and touch the screen edge.
- **Verify:** `WorkspaceSwipeNiriClampTests` (3 tests).

### B9 — Swipes "popped" (destination windows appeared late)
- **Cause (established):** apps hidden by ws-hide had no window to capture.
- **Fix:** stop hiding apps altogether; cover the parked-window strip with margin-veil instead.
  ws-hide kept its name but only refocuses.
- **Missed swipes on diagonal starts (established):** a diagonal start resolved to no mode. Fix existed
  — **not in the current build**.
- **Empty screens on switch (established):** Stage Manager was on; now off (`home-manager/macos.nix`).

### B10 — Grey previews in the Overview
- **Cause (established):** hidden apps cannot be captured; also missing Screen Recording permission.
- **Fix:** no more app hiding (B9). Measured: all previews present at 1 s.
- **Verify:** open the Overview; grey = check Screen Recording for OmniWM.

### B11 — Trackpad gestures fought with macOS (Mission Control behind the Overview)
- **Cause (established):** macOS still owned 3/4-finger swipes (including the per-host key
  `com.apple.trackpad.threeFingerVertSwipeGesture` and the Dock's `showMissionControlGestureEnabled`).
- **Fix:** all of them declared in `home-manager/macos.nix` (applied by Home Manager); `scripts/macos-defaults.sh` checks the live Mac.
- **Verify:** `scripts/macos-defaults.sh` exits 0; `scripts/doctor.sh`.

### B12 — Turning Accessibility off froze all input
- **Cause (established):** on revoke, OmniWM only updated a flag; event taps and observers stayed installed.
- **Fix:** stop services on revoke, restart on re-grant, 1 s trust polling — merged upstream as
  [PR #837](https://github.com/OmniNull/OmniWM/pull/837) (in the pinned commit). Hammerspoon `ax-guard.lua`
  also restarts OmniWM and Neru on any Accessibility change.
- **Verify:** toggle OmniWM in Accessibility settings: input stays fluid.

### B13 — Notch / full-height windows
- All attempts negative or not in this build: negative top gap ignored; full-height option (apps snap back
  below the notch; v2 detected refusing apps but is not in the current build); virtual no-notch display
  (panel draws the mirror below the notch); Ghostty patch abandoned.
- **Current:** windows start below the menu-bar/notch band; `gaps.fullHeightWhenMenuBarHidden` is inert.

### B14 — System Settings lost focus to hover; talagent
- **Cause (established):** floating System Settings became a managed window and bypassed OmniWM's pause
  for external apps. Fix existed — **not in the current build**.
- Never re-enable `com.apple.talagent` (re-enabling froze app switching; `docs/macos.md`).

### B15 — Secure Input explanation panel
- OmniWM shows a panel after 10 s of macOS Secure Input (password fields). Suppression default existed
  — **not in the current build**. Secure Input itself must stay on.

### B16 — A wallpaper change reverted the OmniWM settings
- **Cause (established):** `theme-sync.sh` runs `apply-registry.py`, which rewrote `settings.toml` from a
  stale registry (old gestures, animation 1.6, card Overview).
- **Fix:** registry aligned with the wanted state; `scripts/check.sh` now fails if the registry
  would change the captured `settings.toml`.
- **Verify:** `scripts/check.sh` ("OmniWM registry matches …").

### B17 — Process incidents (rules that came out of them)
- The full OmniWM test suite froze the Mac: run targeted `--filter` tests only.
- A simulated drag landed on the user's active workspace: never simulate input while the user works.
- `capture.sh --accept` overwrote a dirty path with spaces: fixed, regression test in `check.sh`.
- Under zsh `log` is a builtin: always `/usr/bin/log`. `hs -c` can hang: wrap it in `timeout`.
