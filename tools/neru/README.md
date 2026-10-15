# Neru

Keyboard navigation: hints, grid, scroll (Hyper+N / G / S, Esc to leave).

- **Install:** Homebrew cask (tap `y3owk1n/tap`); update with `brew upgrade --cask neru`.
- **Permission:** Accessibility.
- **Start:** LaunchAgent `org.nix-community.home.neru` runs `neru launch` directly (required for TCC), restarted after an
  abnormal exit (ThrottleInterval 30 s), not after Quit. Log: `~/Library/Logs/macos-config/neru.log`.
- **Config:** `~/.config/neru/config.toml` ↔ `tools/neru/config/config.toml`; validate with `neru config validate`.
- **Restore:** `scripts/apply.sh neru --write`; restart with `launchctl kickstart -k gui/$(id -u)/org.nix-community.home.neru`.
- **Debug:** `/usr/bin/log show --predicate 'process == "neru"' --last 1h`.
