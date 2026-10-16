# Changelog

All notable changes. Format: newest first; each entry says what changed and how to roll it back when that
is not a plain `git revert`.

## 1.1.0
- macOS settings declared in Nix (`home-manager/macos.nix`): trackpad, gestures, keyboard and the macOS
  shortcuts disabled for OmniWM/Raycast, Dock, Mission Control, Finder, Stage Manager, appearance;
  `scripts/macos-defaults.sh` now checks them against the live Mac.
- Control+arrows = focus and Control+Shift+arrows = move in all four directions (macOS Mission Control chords
  disabled).
- `identity.nix` reads user, home and clone from the environment: a clean clone builds with no personal value.
- OmniWM patches 0008–0017: bug fixes from earlier local builds (diagonal swipe start, swipe sensitivity,
  wallpaper cache, Secure Input panel, System Settings focus, Overview captures) and focus reliability
  (macOS-checked "already focused", debounce trailing edge, `focus-trace` log); `raiseOnMouseFocus = true`.
- OmniWM patches 0018–0019: on a workspace switch the window landing under the pointer gets focus (not the
  workspace's remembered window); also after a Niri scroll.

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
