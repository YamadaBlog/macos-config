# Hammerspoon

Contexts (Focus / Web / Messages / Atelier: switch OmniWM workspace, then open resources) and small window-manager helpers.

- **Install:** Homebrew cask. **Start:** LaunchAgent `org.nix-community.home.hammerspoon`.
- **Permission:** Accessibility.
- **Depends on:** OmniWM IPC (`omniwmctl`).
- **Config:** `~/.hammerspoon/*.lua` ↔ `tools/hammerspoon/config/`, loaded by `init.lua`:
  - `poweruser.lua` (+ `poweruser-backend.lua`, `poweruser-projects.lua`): contexts, Hyper+P;
  - `poweruser-apps.lua`: apps tied to each context;
  - `ax-guard.lua`: restarts OmniWM and Neru when their Accessibility grant changes;
  - `margin-veil.lua`: catches clicks on the right margin covering parked windows of inactive workspaces;
  - `ws-hide.lua`: restores focus after a workspace switch and feeds margin-veil;
  - `repo-path.lua`: clone location, read from `~/.config/macos-config/repo`.
- **Apply / restore:** `scripts/apply.sh hammerspoon --write`, then reload the config.
