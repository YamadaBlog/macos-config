# Machine status — 2026-10-09

## Update of 2026-10-09
- **Windows**: OmniWM in Dwindle everywhere, one workspace per app (Ghostty 1, Safari 2, Discord 3, Finder 4),
  Ctrl+1..9 / Ctrl+Shift+1..9, Dwindle controls on Ctrl+Option+letter. AeroSpace and native tiling tried, then
  abandoned (AeroSpace uninstalled, config archived in `experiments/aerospace/`).
- **Display**: 1728×1117 Retina (2×) instead of 3456×2234 at 1×; OmniWM top margin 40.
- **Theme**: `theme-auto.sh` rechecks the wallpaper index at the end of each run (fixes a missed rapid change); real double change ⏳.
- **Notch**: OmniWM option `fullHeightWhenMenuBarHidden` v2 and Ghostty option `macos-window-avoid-notch` prototyped
  (`experiments/omniwm-full-height/`); real trial blocked (OmniWM Dev Accessibility), then paused.
- **Raycast export** moved out of the repo: `~/.local/share/macos-config-private/raycast/`.
- **Permissions to remove** (Settings › Accessibility): OmniWM Dev, AeroSpace, bash `/nix/store/…`, BetterDisplay, BetterTouchTool.


Three independent states. Evidence: **M** manual (user) · **S** simulated · **I** inspection · **R** restore performed · **—** not tested.

## 1. Configuration and compliance — ACCEPTABLE
`scripts/verify.sh --hm` → exit 0 (coverage, sheets, effective permissions, configurations, Brewfile, snapshots, Home Manager).
Detailed base (OmniWM, Neru, Hammerspoon, Raycast, Ghostty, Finder, Stats, startup, logs, recovery): `CHANGELOG.md`
and `tools/` sheets. Decisions of 2026-10-08: OmniWM border/bar **disabled** (by choice), BetterTouchTool **uninstalled**.

| Category | Item | State |
|---|---|---|
| **Security alert** (outside compliance) | Accessibility entry `/nix/store/hr5jdf535nm54yq3jzkyx8k9a0m3hwql-bash-5.3p9/bin/bash` — denied at 15:55, **re-enabled at 16:09:51** in Settings | ⏳ removal requested ("–") |
| Remaining cleanup (optional) | BetterDisplay entries (app absent) and BetterTouchTool ×3 (uninstalled) | ⏳ removal requested |
| Configuration choice | OmniWM border/bar | ✅ decided: disabled; repo and script aligned |
| Optional cleanup | BetterTouchTool | ✅ uninstalled (leftover data kept) |
| Retention | `~/Projects/macos-config` | kept |

## 2. Daily and post-session validation — REMAINING
| # | Test | S | M |
|---|---|---|---|
| 1 | AZERTY typing, dead keys, non-breaking space | ✅ | ⏳ |
| 2 | 3-finger horizontal = columns | — | ⏳ |
| 3 | 2 fingers = content scrolling | — | ⏳ |
| 4 | macOS gestures (3 fingers up, 4 fingers) | — | ⏳ |
| 5 | Hyper+W/E/D/T | ✅ | ⏳ |
| 6 | Hyper+Shift move | ✅ | ⏳ |
| 7 | Overview Hyper+O | ✅ | ⏳ |
| 8 | Contexts Hyper+P | ✅ | ⏳ |
| 9 | Neru hints | ✅ | ⏳ |
| 10 | Ghostty | ✅ | ⏳ |
| 11 | Raycast | ✅ | ⏳ |
| 12 | Sleep / wake | — | ⏳ |
| 13 | Restart + `post-session-check.sh` | ✅ (unplanned restart 20:45: 1 instance of each tool, IPC, 4 workspaces, Neru, Accessibility OFF, Lix OK) | keyboard functions ⏳ |

## 3. Backup and recovery — OPEN (does not block acceptance of the base)
| Item | State |
|---|---|
| Time Machine | **not configured** — no destination chosen; **the machine is not backed up** |
| Restore of a test file | not done |
| Raycast export | ⏳ to do (password kept by the user); the export itself must be backed up off the Mac |
| Lunar / Terminal exports | present (private folder, same disk); re-import not tested |
| Config rollback | **R** (btop file, TopNotch plist) |
| Emergency stop / restart | S (also without shell profile) |
| Rebuild on a clean Mac | **not tested** |

## Limits
- Neru: crash at 14:15:29 = internal libdispatch assertion; unknown trigger; restarts without cap (≥ 30 s).
- TopNotch/Stats usage data in local Git history (low sensitivity, kept — `docs/secrets.md`).
- Heuristic secret detection; login items, Raycast extensions and Safari extension activation cannot be inventoried.
- Unknown origins: `default.store`, `~/dock-backup.plist`, OmniWM disabling at 15:34, `bash` re-enabling at 16:09.
