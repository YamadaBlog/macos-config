# OmniWM

The only window manager: workspaces 1–9, app rules, Dwindle on workspace 1 and Niri elsewhere, trackpad gestures, Overview.
Border and bar disabled by choice. Details: `docs/omniwm.md`.

- **Build:** pinned upstream commit in `UPSTREAM` + `patches/*.patch`, built and signed by `build-local.sh` with a
  self-signed certificate from `create-signing-cert.sh`. Requires Xcode.
- **Config:** `~/.config/omniwm/settings.toml` ↔ `tools/omniwm/config/settings.toml`. `apply-registry.py` enforces
  shortcuts, gestures and layout, and computes `singleWindowFit` from the main display.
- **Used by:** Hammerspoon via IPC (`omniwmctl`).
- **Permissions:** Accessibility + Screen Recording (re-grant if the signing identity changes).
- **Start:** LaunchAgent `org.nix-community.home.omniwm`.

## Update
1. Change the commit in `UPSTREAM`.
2. Rebase the patches on it and regenerate `patches/*.patch`.
3. `build-local.sh --check`, then build and install.

## Rollback
Quit OmniWM, put back `~/.local/state/macos-power-user-deploy/backups/OmniWM-local-prev.app`, then
`launchctl kickstart gui/$(id -u)/org.nix-community.home.omniwm`. Config: copy back `backups/omniwm-*/settings.toml`.
See `docs/recovery.md`.
