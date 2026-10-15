#!/bin/bash
# Guided installation of this setup on a Mac (new or existing). Read README.md first.
#
#   ./install.sh              PLAN: checks prerequisites and shows every step; changes nothing
#   ./install.sh --run        runs the steps in order; asks before each one ([y]es / [s]kip / [q]uit)
#   ./install.sh --run STEP   runs one step only (names below)
#
# Steps: identity, backup, homebrew, home-manager, macos, omniwm, configs, permissions, doctor
# Every step is idempotent (safe to re-run) and backs up what it replaces under
# ~/.local/state/macos-power-user-deploy/backups/. Nothing is deleted. Rollback: README "Rollback".
# Never run with sudo: the steps that need an admin password (Lix, Homebrew) ask for it themselves.
set -uo pipefail
REPO="$(cd "$(dirname "$0")" && pwd)"
STATE="$HOME/.local/state/macos-power-user-deploy"
BK="$STATE/backups/install-$(date +%Y%m%d-%H%M%S)"
mode="${1:-plan}"; only="${2:-}"
[ "$(id -u)" = 0 ] && { echo "Do not run as root." >&2; exit 2; }
say() { printf '\n\033[1m== %s\033[0m\n' "$*"; }
ask() {  # ask "question" -> 0 yes, 1 skip; q quits
  [ "$mode" = --run ] || return 1
  local a; read -r -p "$1 [y/s/q] " a </dev/tty
  case "$a" in y|Y|o|O) return 0;; q|Q) echo "Stopped."; exit 0;; *) return 1;; esac
}
backup() { [ -e "$1" ] || return 0; mkdir -p "$BK$(dirname "$1")"; cp -pR "$1" "$BK$1"; echo "  backed up $1 -> $BK$1"; }

prereqs() {
  say "Prerequisites"
  local bad=0
  [ "$(uname -m)" = arm64 ] || { echo "  Apple Silicon Mac required."; bad=1; }
  echo "  macOS $(sw_vers -productVersion) (tested: 26.x)"
  xcode-select -p >/dev/null 2>&1 || { echo "  MISSING Xcode command line tools: xcode-select --install"; bad=1; }
  [ -d /Applications/Xcode.app ] || echo "  MISSING Xcode.app (App Store) - needed only for the OmniWM step"
  command -v brew >/dev/null || echo "  MISSING Homebrew - step homebrew explains how to install it"
  command -v nix  >/dev/null || [ -x /nix/var/nix/profiles/default/bin/nix ] || echo "  MISSING Nix (Lix) - step home-manager explains how to install it"
  echo "  user=$(id -un) home=$HOME repo=$REPO"
  return $bad
}

step_identity() {
  say "identity: write your username, home and repo location (home-manager/identity.nix, ~/.config/macos-config/repo)"
  echo "  username=$(id -un) homeDirectory=$HOME repoDir=$REPO"
  ask "Write these values?" || return 0
  printf '# Machine-specific values. Written by ./install.sh (from `id -un`, $HOME and the clone location);\n# edit by hand only if you do not use install.sh.\n{ username = "%s"; homeDirectory = "%s"; repoDir = "%s"; }\n' "$(id -un)" "$HOME" "$REPO" > "$REPO/home-manager/identity.nix"
  # Keep these values local: git keeps the placeholder, Nix reads the file on disk.
  git -C "$REPO" update-index --skip-worktree home-manager/identity.nix
  mkdir -p "$HOME/.config/macos-config"; echo "$REPO" > "$HOME/.config/macos-config/repo"
  echo "  done (identity.nix is now local to this Mac: git ignores its changes)"
}

step_backup() {
  say "backup: copy the dotfiles and app configs this setup will manage"
  local f
  for f in .zshrc .zshenv .zprofile .config/starship.toml .config/ghostty .config/omniwm .config/neru .hammerspoon .config/atuin; do
    [ -e "$HOME/$f" ] && echo "  will back up ~/$f"
  done
  ask "Back them up to $BK ?" || return 0
  for f in .zshrc .zshenv .zprofile .config/starship.toml .config/ghostty .config/omniwm .config/neru .hammerspoon .config/atuin; do backup "$HOME/$f"; done
}

step_homebrew() {
  say "homebrew: install the GUI apps of homebrew/Brewfile (no uninstall, no upgrade of what you have)"
  if ! command -v brew >/dev/null; then
    echo "  Homebrew is not installed. Read https://brew.sh then run its official install command yourself,"
    echo "  open a new terminal and re-run: ./install.sh --run homebrew"; return 0
  fi
  HOMEBREW_NO_AUTO_UPDATE=1 brew bundle check --file="$REPO/homebrew/Brewfile" --verbose 2>/dev/null | grep '→' | sed 's/^/  /'
  ask "Run brew bundle install?" || return 0
  brew bundle install --no-upgrade --file="$REPO/homebrew/Brewfile"
}

step_home_manager() {
  say "home-manager: CLI tools, zsh + Starship + Atuin, theme (Stylix), LaunchAgents (OmniWM, Hammerspoon, Neru, Stats, theme-auto)"
  if ! command -v nix >/dev/null && [ ! -x /nix/var/nix/profiles/default/bin/nix ]; then
    echo "  Nix is not installed. This setup uses Lix: read https://lix.systems/install/ and run its installer"
    echo "  yourself (it asks for your password), open a new terminal, then: ./install.sh --run home-manager"; return 0
  fi
  grep -q "username = \"$(id -un)\"" "$REPO/home-manager/identity.nix" || { echo "  Run the identity step first."; return 0; }
  echo "  Existing ~/.zshrc etc.: Home Manager refuses to overwrite unmanaged files; it fails and lists them."
  echo "  They were backed up by the backup step: move them aside (mv ~/.zshrc ~/.zshrc.before-hm) and re-run."
  ask "Build and activate the Home Manager configuration?" || return 0
  "$REPO/scripts/apply.sh" home-manager --write
}

step_macos() {
  say "macos: Dock, Finder, keyboard repeat, trackpad gestures handed to OmniWM, Mission Control gesture off"
  "$REPO/scripts/macos-defaults.sh"
  ask "Apply (a restore script is written first)?" || return 0
  "$REPO/scripts/macos-defaults.sh" --write
}

step_omniwm() {
  say "omniwm: build the patched OmniWM (upstream $(cut -c1-8 "$REPO/tools/omniwm/UPSTREAM") + tools/omniwm/patches) and install it"
  [ -d /Applications/Xcode.app ] || { echo "  Install Xcode first (App Store), open it once, then re-run this step."; return 0; }
  echo "  1. creates the code-signing certificate \"OmniWM Local Signing\" in your login keychain (once)"
  echo "  2. clones upstream to \${OMNIWM_SRC:-~/src/omniwm}, applies the patches, builds (several minutes)"
  echo "  3. replaces /Applications/OmniWM.app (previous app kept in $STATE/backups/OmniWM-local-prev.app)"
  ask "Build and install OmniWM?" || return 0
  "$REPO/tools/omniwm/create-signing-cert.sh" && "$REPO/tools/omniwm/build-local.sh"
}

step_configs() {
  say "configs: copy the app configs from the repo (OmniWM settings, Hammerspoon, Neru, Stats); each file is backed up"
  echo "  OmniWM must be quit while its settings.toml is written (it rewrites the file otherwise)."
  ask "Apply the configs?" || return 0
  osascript -e 'quit app "OmniWM"' 2>/dev/null; sleep 2
  local id
  for id in omniwm hammerspoon neru stats; do "$REPO/scripts/apply.sh" "$id" --write; done
  # The window size for a lone window follows THIS screen (apply-registry.py computes it).
  python3 -I "$REPO/tools/omniwm/apply-registry.py" "$HOME/.config/omniwm/settings.toml" --write | tail -1
  open -g -a OmniWM; open -g -a Hammerspoon
}

step_permissions() {
  say "permissions: macOS only lets YOU grant these (System Settings > Privacy & Security)"
  cat <<'EOF'
  Accessibility      : OmniWM, Hammerspoon, Neru          (window control, hotkeys)
  Screen Recording   : OmniWM                             (Overview and swipe previews)
  Input Monitoring   : OmniWM (if asked)                  (trackpad gestures)
  After granting, quit and reopen each app. Details and why: docs/macos.md "Permissions".
EOF
  ask "Open the Accessibility pane now?" || return 0
  open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
}

step_doctor() { say "doctor: final diagnostic"; "$REPO/scripts/doctor.sh"; }

case "$mode" in
  plan|--plan)
    prereqs
    echo; echo "Plan (nothing was changed). Run: ./install.sh --run   (asks before each step)"
    echo "  identity -> backup -> homebrew -> home-manager -> macos -> omniwm -> configs -> permissions -> doctor";;
  --run)
    prereqs || { echo "Fix the prerequisites above first."; exit 1; }
    if [ -n "$only" ]; then "step_${only//-/_}"; exit $?; fi
    step_identity; step_backup; step_homebrew; step_home_manager; step_macos; step_omniwm; step_configs; step_permissions; step_doctor;;
  *) sed -n '2,12p' "$0"; exit 2;;
esac
