# [Feature request] Option: use the full display height when the menu bar is auto-hidden (notched displays)

*Draft to open as an issue/discussion on OmniNull/OmniWM before any PR, as CONTRIBUTING.md asks for behaviour changes.*

## Problem
On notched MacBooks with the menu bar set to auto-hide ("Always"), `NSScreen.visibleFrame` still excludes the notch band
(≈ 40 pt on a 16"). `buildLayoutFrames` uses `monitor.visibleFrame` and `normalizedTopStrut(top:menuBarInset:)`
(see #612), so tiled windows can never start above that band, even with `[gaps.outer] top = 8`. The band stays empty
(wallpaper), while users want a uniform 8 pt margin on all sides.

## Proposal
New opt-in setting, default `false` (no behaviour change):
```toml
[gaps]
fullHeightWhenMenuBarHidden = true   # per-monitor override like fullscreenUsesOuterGaps
```
When enabled **and** the menu bar is auto-hidden, the layout parent area becomes `monitor.frame` for its top edge
(`menuBarInset = 0`), so `outer.top` is measured from the physical top as documented.

## Important caveat (measured on macOS 26.6, 2026-10-08)
Most AppKit apps re-constrain their own windows below the menu bar/notch in `-[NSWindow constrainFrameRect:toScreen:]`:
setting a floating Finder/Safari/Ghostty window to y = 5 via AX snaps back to y = 40. With that constraint removed
inside the app, a window stays at y = 8. So this option only helps apps that do not self-constrain; OmniWM should
treat a snapped-back frame as normal (no retry loop). We'd like the maintainers' view on whether that is acceptable.

## Measured result with a prototype (macOS 26.6, 2026-10-08)
A local prototype (opt-in `fullHeightWhenMenuBarHidden`, tests passing) requested frames 8 pt below the physical top.
Every app tried (Preview, Safari, Ghostty, Terminal — AppKit — and Discord — Electron) snapped its window back below the
notch band **and** was shifted/clipped at the bottom (bottom margin 8 → 0). So the option alone makes layouts worse;
it would only help apps that do not self-constrain. Sharing this as data rather than proposing a PR as-is.

## Testing plan
- Unit: `GapSettingsTests` (default false, TOML round-trip, per-monitor override), layout test asserting working frame
  top = frame.maxY - outer.top when enabled + menu bar hidden, unchanged otherwise.
- Manual: notched MacBook, menu bar hidden/visible, one app that self-constrains (Safari) and one that does not.
