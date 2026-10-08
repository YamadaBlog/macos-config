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
