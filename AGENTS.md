# AGENTS.md — taking over this machine

Reference repo for **mao**'s MacBook Pro: `~/dev/macos-config` (local, private, no remote).
Working language: English.

## 1. Where to start (reading order)
1. `STATUS.md` — what is tested, configured, pending; **remaining actions and criteria**.
2. `docs/architecture.md` — who manages what (responsibility table, flows).
3. `docs/raccourcis.md` — single registry of AZERTY shortcuts and gestures.
4. `inventory/elements.tsv` — structured inventory (1 line per installed item).
5. `tools/<tool>/README.md` — sheet for each tool.
6. `CHANGELOG.md` — dated history of changes on the machine.

**Authority, in this order**: the actual machine state (checked by `scripts/verify.sh`) > this repo
(`STATUS.md`, `inventory/`, `docs/`, `tools/`) > `kit/` (original templates, **never** the actual state).
The old `~/Projects/macos-config` folder is **abandoned** (kept, deletion not authorized):
do not read or modify it. Private deployment state lives in `~/.local/state/macos-power-user-deploy/`
(log, evidence, backups: never commit it).

## 2. Repo layout
```
AGENTS.md README.md STATUS.md CHANGELOG.md
inventory/elements.tsv   inventory (17 columns; "detection" = keys produced by discover.sh)
inventory/configs.tsv    live config ↔ repo copy mapping (read by capture/apply/verify)
inventory/ignore.tsv     items deliberately not inventoried (Apple apps, caches…)
home-manager/            Home Manager flake — THE REPO IS THE SOURCE (apply, do not capture)
homebrew/Brewfile        installed apps (generated); homebrew/modules/ = kit modules
tools/<tool>/            README (sheet) + config/ (captured copy) + tool-specific scripts
nix-darwin/              declarative Finder/Dock — prepared, NOT activated
docs/                    architecture, shortcuts, macos, permissions, startup, secrets,
                         sync, restore, rebuild, debloat, inventory
docs/generated/          snapshots produced by scripts/snapshot.sh (do not edit)
scripts/                 discover / capture / apply / verify / snapshot (+ sync.sh = entry point)
kit/                     archived original kit
```

## 3. Work cycle
| Step | Command | Effect |
|---|---|---|
| Discover | `scripts/discover.sh` | lists what is installed (read-only) |
| Verify | `scripts/verify.sh [--hm]` | inventory coverage, sheets, config/Brewfile/snapshot drift; exit 1 on drift |
| Capture | `scripts/capture.sh` then `scripts/capture.sh --accept` | machine → repo, diff shown, rejects secrets and uncommitted paths |
| Apply | `scripts/apply.sh <id>` then `--write` | repo → machine, backup first, rollback command shown |

After any change: `verify.sh` → `capture.sh` → review `git diff` → commit → line in `CHANGELOG.md`
→ status in `STATUS.md`.

## 4. Change rules
- **One owner per function** (`docs/architecture.md`). Never add a second WM, launcher, clipboard or gesture engine.
- New tool = line in `inventory/elements.tsv` (detection keys) + sheet `tools/<id>/README.md`
  + line in `inventory/configs.tsv` if a config is capturable. `verify.sh` must return 0 again.
- CLI → Home Manager (`home-manager/home.nix`); GUI apps → `brew install --cask` then capture the Brewfile.
- Shortcuts: follow `docs/raccourcis.md` (never Option alone; OmniWM = QWERTY positions).
- OmniWM: quit it before editing `settings.toml` (otherwise it rewrites it); workspace `name` = digit, label = `displayName`.
- Never commit: secrets, histories, sessions, app databases (`docs/secrets.md`). `capture.sh` rejects secret patterns.
- No `--force` to resolve a conflict, no `rm -rf` on data; back up before writing.
- Distinguish **installed / configured / tested**; a test not observed stays "pending".

## 5. Machine constraints
- MacBook Pro Mac17,6 (M5 Max, 64 GB), macOS 26.6 (25G72), **French AZERTY** keyboard, natural scrolling.
- SIP disabled, SSV sealed: **out of scope** — do not touch SIP, SSV, boot-args, Secure Boot, sudoers.
- Pre-existing `dev-minimal` debloat (154 services disabled): Shortcuts broken, dictation probably broken
  (`docs/debloat.md`). No new debloat, no global restore.
- No Time Machine configured → no heavy migration and no nix-darwin activation.
- Admin passwords never go through an assistant: the user runs the command themselves.
- TCC permissions (Accessibility, Screen Recording): only via System Settings, by the user.
- The Claude Code session runs in **Terminal.app**; Ghostty is installed and configured.
- Testing without a physical keyboard: `hs -c 'hs.eventtap.keyStroke(...)'` (arrows: add `fn`; AZERTY: pass
  key codes, `keyStrokes` sends Unicode that Raycast ignores); `omniwmctl query …`; `neru status`.
  `hs -c` can hang: call it with a timeout, e.g. `( hs -c '…' & p=$!; sleep 6; kill $p ) 2>/dev/null`.
- Apps respond to simulated clicks; a Raycast "Request to run …" prompt is approved once (never "Always").
- Private exports (Raycast, Lunar, Terminal): `~/.local/share/macos-config-private/` (`docs/secrets.md`).
- Manual tests to ask the user for: `docs/tests-manuels.md`. Module decisions: `docs/decisions.md`.
- A terminal window opened before a shell change keeps the old environment: open a new one.
- **Unified log: always `/usr/bin/log`**; under zsh, `log` is a builtin that reads nothing (mistake made on 2026-10-08).
- **TCC-gated apps (Neru…): launch them directly from a LaunchAgent**, never via a parent script (Neru reset its Accessibility).
- Theme: `tools/stylix/README.md` (palette in `home-manager/theme.nix`, applied elsewhere by `scripts/theme-apply.sh`).
- **Never run OmniWM's full test suite (`swift test`) on the machine in use**: it froze the Mac on 2026-10-08; targeted `--filter` tests only.
- Machine lockup: `docs/recuperation.md`, `scripts/emergency-stop.sh` / `emergency-start.sh`.

## 6. Remaining actions (validation criteria)
See `STATUS.md` (sections A–D, evidence M/S/I/R), `docs/actions-humaines.md` (H1–H7) and `docs/tests-manuels.md` — the only up-to-date lists.

## Accessibility and window managers (incident 2026-10-09)
- Turning off OmniWM's Accessibility while it runs froze all input outside the focused app (event taps left installed).
- Guard: `tools/hammerspoon/config/ax-guard.lua` restarts OmniWM and Neru on every `com.apple.accessibility.api` notification (15 s cooldown).
- Fix (stop services on revoke + 1 s trust polling) VERIFIED for real on 2026-10-09 (toggle turned off in Settings: input stayed fluid) and INSTALLED: `/Applications/OmniWM.app` is a local ad-hoc build of `~/dev/omniwm` branch `stop-services-on-ax-revoke` (bundle id unchanged). Auto-updates off (`updateChecksEnabled = false`). Official 0.7.6 backup: `~/.local/state/macos-power-user-deploy/backups/OmniWM-officiel-0.7.6.app`. Build with `tools/omniwm/build-local.sh [branch]`: it signs with the local self-signed certificate "OmniWM Local Signing" (login keychain, codesign-only access), so permissions SURVIVE rebuilds. Never build with ad-hoc signing (`package-app.sh` alone) or permissions are lost.
- Never re-enable `com.apple.talagent` (see `docs/debloat.md`). In Hammerspoon, keep references to `hs.timer` objects. Do not call `hs.reload()` through `hs -c` (IPC gets stuck); restart the app instead.

## Parked-window strip in the right margin (2026-10-09)
- Cause: OmniWM parks inactive-workspace windows 1 px inside the right edge; their edge + shadow darken the 8 px margin.
- Rejected: right margin 0 (user rule: no window touches an edge); bottom-right corner parking (macOS pulls the title bar back on screen: a 246×52 px block stayed visible; WIP branch `hide-inactive-in-corner`).
- Fix: `tools/hammerspoon/config/ws-hide.lua` subscribes to OmniWM `active-workspace` and hides (Cmd+H) apps with no window on the active workspace, unhides the others. Measured: edge clean, windows in place in ~0.12 s; also after moving Safari Web→Focus→Web.
- Limit: an app with windows on SEVERAL workspaces cannot be hidden (it would hide the visible ones too), so its parked windows still show at the right edge. Keep one app per workspace (OmniWM rules).

## Drag-and-drop insertion (2026-10-09)
- Local OmniWM branch `dwindle-drag-insert` (on top of the Accessibility fix): plain title-bar drag (dropped on mouse up) or Option+drag, drop near a tile edge (outer 30 % band) → window removed from the tree (space reabsorbed) and inserted beside the target; center (inner 40 %) → swap as upstream.
- Verified live with simulated Option+drag (left-edge insert, center swap, top-edge insert) and 8 tests in `DwindleInteractiveMoveTests`. Installed with `tools/omniwm/build-local.sh dwindle-drag-insert`.
- Never simulate mouse input while the user is using the Mac: a test drag landed on their active workspace (2026-10-09).
- ws-hide also gives focus after a switch (window under the pointer, else first window): OmniWM's own focus fails while the app is still hidden. Verified: Ctrl+2 → Safari focused 3/3.
