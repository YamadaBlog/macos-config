# Niri scroll measurements

Tools used to measure the horizontal Niri scroll (2026-10). They need the OmniWM bench patch
(`notifyutil -p com.barut.OmniWM.bench.columnScroll` replays a fixed 3-finger gesture; each run writes the
targets OmniWM computed to `~/Library/Logs/OmniWM/scroll-bench.tsv`).

| File | Measures |
|---|---|
| `analyze-scroll-trace.py TRACE` | OmniWM side, from a trace capture (`omniwmctl capture start trace`): frame pacing, AX write times, per-window update gaps, column desync, tracking error |
| `poll.swift` → `poll SECONDS WID…` | WindowServer side: each window's on-server x every 2 ms |
| `analyze-windowserver.py PREFIX` | calculated → WindowServer latency, gaps between displayed updates, desync (`PREFIX-N.poll` + `.tsv`) |
| `film.swift` → `film SECONDS` | pixels: the display at 120 fps (ScreenCaptureKit), left edge of solid red / green / blue windows on the middle row |
| `analyze-pixels.py PREFIX WID:COL:OFFSET…` | calculated → pixels latency, frames without movement, reversal latency, spacing, end-of-gesture step |
| `testapp.swift` | test windows: `testapp color:1,0,0 color:0,1,0 color:0,0,1` (solid colours for `film`) or URLs (WebKit pages); `WKTEST_SELFMOVE=1` moves its own window every frame (control without Accessibility) |

Build: `swiftc -O film.swift -o film` (same for `poll`, `testapp`). `film` needs Screen Recording for the terminal.

## Protocol (never on personal workspaces)
1. `omniwmctl command switch-workspace anywhere 5` and **check** `omniwmctl query active-workspace` says 5;
   abort otherwise (test windows open on the active workspace). Do not run while someone uses the Mac.
2. Open the test windows there, note their ids and, for `film`, the offset between the x OmniWM reports at rest and
   the pixel `film` sees.
3. Per run: `focus-column 1`, start `film`/`poll`, post the bench notification, copy `scroll-bench.tsv`.
   Alternate the settings being compared run by run; use ≥ 8 runs per setting.
4. Close the test windows and compare the window list with the one taken before.

## Results that shaped the code (2026-10-17)
- OmniWM's own work: ~0.1 ms per frame; its computed positions are perfectly regular (9 pt every 8.33 ms).
- A window an app moves itself (display link): 16.6 ms to pixels. The same move through Accessibility: 24.9 ms —
  AppKit sends window changes to the WindowServer on its own display-link flush, and OmniWM wrote right after it.
- `TickLeadMs` (run the tick that long before the next frame): the write must reach the app clearly before its
  flush. 2-3 ms and the adaptive mode (−1, which settles near 1.5-2 ms) straddle it: lower median latency but
  frozen-then-double frames in slow motion (light app 91-94 % regular images instead of 100 %). **5 ms**: light app
  100 % regular, 26.5 → 21.3 ms to pixels; Safari same regularity, 13.9 → 10.4 ms p50 to the WindowServer. 6 ms:
  no gain (past the flush again).
- Measurement pitfalls met: a window whose left edge leaves the screen reports a clipped, frozen edge (keep
  40 < x < 2000 for both target and pixels); ScreenCaptureKit skips images when nothing changes, and a 16.7 ms
  interval occurs ~1 in 13 images even for an app moving its own window (not caused by OmniWM); a display "clock"
  drawn by a background app runs below 120 Hz and cannot serve as a reference.
- Safari on pixels (local solid-colour pages served over http, `film` thresholds widened for the P3 display):
  two Safari windows moving together show the usual cadence in only ~69 % of images (frozen, then double steps);
  one Safari window moving alone 92 % (= the capture floor, smooth); a WKWebView in a plain app 91 %. The cost
  is per Safari process and per moved window, not WebKit and not OmniWM. A 5 ms tick lead makes Safari worse
  (69 → 51 %) although it helps a light app; a half-rate experiment for Safari changed nothing.
- Safari spends ~2.5 ms per move saving its window frame and restoration archive (unconditional for normal
  windows: read in its code), and froze ~500 ms while `com.apple.synapse.contentlinkingd` was disabled
  (`docs/bugs.md` B18).
