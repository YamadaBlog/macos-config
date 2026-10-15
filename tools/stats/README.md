# Stats

Menu-bar monitor limited to CPU, RAM and network (battery, GPU, sensors and disk modules off).

- **Install:** Homebrew cask. **Start:** LaunchAgent `org.nix-community.home.stats`.
- **Permission:** none required.
- **Config:** domain `eu.exelban.Stats` ↔ `tools/stats/config/eu.exelban.Stats.plist` (device id and volatile keys stripped on capture).
  A module can be toggled with `defaults write eu.exelban.Stats <Module>_state -bool false`.
- **Restore:** quit Stats, then `scripts/apply.sh stats --write`.
