# Changelog

All notable changes. Format: newest first; each entry says what changed and how to roll it back when that
is not a plain `git revert`.

## 1.0.0 — first public release
- Guided installation (`install.sh`), diagnostic (`scripts/doctor.sh`), drift check (`scripts/verify.sh`),
  declarative macOS settings with a restore script (`scripts/macos-defaults.sh`).
- OmniWM built from a pinned upstream commit plus 7 patches (Overview without labels/search bar, clean
  screen edges, sharp and colour-accurate workspace swipes, no Niri column overlap during swipes), signed
  with a local certificate so macOS permissions survive rebuilds.
- Home Manager flake: CLI tools, zsh + Starship + Atuin, Ghostty and Stylix theme generated from the
  wallpaper, login agents. No machine-specific value in the code (`identity.nix` written by the installer).
- Hammerspoon helpers: contexts, refocus after workspace switches, screen-edge veil, Accessibility guard.
- Documentation: README, `AGENTS.md`, OmniWM reference, shortcuts, architecture, macOS, recovery, and a
  catalogue of the bugs met while building this setup with their causes and checks (`docs/bugs.md`).
