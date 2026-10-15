# macOS settings, permissions, startup and secrets

## System settings
All macOS preferences this setup changes are declared in **`scripts/macos-defaults.sh`** (single source of truth;
values are not repeated here). It covers Dock, Finder, Spaces, menu bar, keyboard shortcuts and trackpad, including:
- Spaces not reordered by use; Stage Manager off (it fights OmniWM: empty screens, windows piled up as thumbnails);
- macOS Ctrl+←/→ Space shortcuts (symbolichotkeys 79–82) disabled for OmniWM; Spotlight's Cmd+Space (64) disabled for Raycast;
- macOS 3/4-finger swipes and the Mission Control gesture disabled (OmniWM owns them, see `docs/shortcuts.md`).

Run it without arguments to preview, with `--write` to apply. `--write` first creates a restore script
(see `docs/recovery.md`). `scripts/verify.sh` flags drift (e.g. Stage Manager turned on from Control Center).

Notes:
- On a display with a notch, macOS keeps the top band out of the usable area even with the menu bar hidden;
  hiding the menu bar frees no space for windows there.
- Do not re-enable `com.apple.talagent` if a debloat tool disabled it.
- nix-darwin is not used: see `docs/architecture.md`.

## Permissions (TCC)
Only the user can grant a permission: System Settings > Privacy & Security > <service>.
(requires Full Disk Access for the terminal, otherwise the section is reported as not checkable).

| App | Permission | Why |
|---|---|---|
| OmniWM | Accessibility | move and resize windows |
| OmniWM | Screen Recording | Overview and swipe previews |
| Neru | Accessibility | find clickable elements |
| Hammerspoon | Accessibility | hotkeys, contexts, focus handling |
| Raycast | Accessibility | paste and snippets |

Grant nothing else (Input Monitoring is not needed). An app update that changes the code signature can revoke a grant
(`verify.sh` then reports it missing); a locally built OmniWM must be re-granted if its signing certificate changes.

**Rule:** a TCC-gated app must be launched **directly** by its LaunchAgent (`ProgramArguments`), never through a
parent script — otherwise macOS attributes the permission to the wrong process and can reset it.

## Startup (login items)
One mechanism per tool. Login items are Home Manager LaunchAgents declared in `home-manager/startup.nix`:

| Agent (`org.nix-community.home.*`) | Starts |
|---|---|
| `omniwm` | OmniWM (`open -g -a OmniWM`) |
| `hammerspoon` | Hammerspoon |
| `neru` | `neru launch`, restarted after an abnormal exit (ThrottleInterval 30 s), not after Quit |
| `stats` | Stats |
| `theme-auto` | `scripts/theme-auto.sh` when the wallpaper changes |

A log-rotation agent also trims `~/Library/Logs/macos-config/`. Raycast uses its own "Open at Login" setting.
Do not also enable "launch at login" inside OmniWM, Hammerspoon, Neru or Stats. In System Settings > General > Login Items
the agents appear as **"sh"** (they start via `/bin/sh -c "wait4path /nix/store && exec …"`); this is expected.
Plists are rewritten on every `home-manager switch`, so editing `startup.nix` takes effect on activation.
Check: `launchctl list | grep org.nix-community.home`.

## Secrets and personal data
**Never commit**: tokens, SSH/GPG keys, passwords, shell/Atuin/clipboard histories, sessions, app databases,
account identifiers, or exports of apps that store keys.

- A secret a config needs goes into an ignored file (`*.secret`, `*.env`, `secrets/`) or the keychain
  (`security add-generic-password`); the repo references only its name.
- Private exports (e.g. an encrypted Raycast `.rayconfig`) live **outside the repo**, for instance in
  `~/.local/share/macos-config-private/` (mode 700), backed up to encrypted external storage.
- Capture refuses files matching secret patterns (`SECRET_RE` in `scripts/lib.sh`) and strips identifiers from plists
  (`remote_id`, `device_id`, dates, counters, window positions). This is not a guarantee: review diffs and run
  `git diff --cached | rg -i 'token|secret|password|api.?key'` (or `gitleaks`) before committing.
- If a secret is committed: revoke/rotate it at the source first, then rewrite history.
