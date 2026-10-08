#!/bin/bash
# Produit les instantanés lisibles (réglages macOS, démarrage, versions, raccourcis OmniWM)
# dans le dossier passé en argument (défaut : sortie temporaire affichée).
. "$(dirname "$0")/lib.sh"
out="${1:?usage: snapshot.sh <dossier>}"; mkdir -p "$out"
{
  printf 'domaine\tclé\tvaleur\n'
  while read -r d k; do
    v="$(defaults read "$d" "$k" 2>/dev/null | tr '\n' ' ' | sed 's/  */ /g; s/ *$//')"; printf '%s\t%s\t%s\n' "$d" "$k" "${v:-(absent = défaut macOS)}"
  done <<'EOF'
com.apple.dock autohide
com.apple.dock tilesize
com.apple.dock orientation
com.apple.dock show-recents
com.apple.dock magnification
com.apple.dock mru-spaces
com.apple.dock wvous-tl-corner
com.apple.dock wvous-tr-corner
com.apple.dock wvous-bl-corner
com.apple.dock wvous-br-corner
com.apple.spaces spans-displays
com.apple.finder ShowPathbar
com.apple.finder ShowStatusBar
com.apple.finder FXPreferredViewStyle
com.apple.finder NewWindowTarget
com.apple.finder FXDefaultSearchScope
com.apple.finder AppleShowAllFiles
NSGlobalDomain AppleShowAllExtensions
NSGlobalDomain AppleInterfaceStyle
NSGlobalDomain AppleAccentColor
NSGlobalDomain AppleHighlightColor
NSGlobalDomain _HIHideMenuBar
NSGlobalDomain KeyRepeat
NSGlobalDomain InitialKeyRepeat
NSGlobalDomain ApplePressAndHoldEnabled
NSGlobalDomain com.apple.swipescrolldirection
NSGlobalDomain com.apple.keyboard.fnState
NSGlobalDomain AppleKeyboardUIMode
com.apple.AppleMultitouchTrackpad Clicking
com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag
com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture
com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipeGesture
com.apple.AppleMultitouchTrackpad TrackpadFourFingerHorizSwipeGesture
com.apple.AppleMultitouchTrackpad TrackpadFourFingerVertSwipeGesture
com.apple.controlcenter "NSStatusItem Visible Battery"
com.apple.menuextra.clock ShowSeconds
com.apple.screencapture location
EOF
  printf 'HIToolbox\tdisposition\t%s\n' "$(defaults read com.apple.HIToolbox AppleSelectedInputSources 2>/dev/null | awk -F'= ' '/KeyboardLayout Name/{gsub(/;/,"",$2);print $2}' | tr '\n' ' ' | sed 's/ *$//')"
  printf 'symbolichotkeys\t64 Spotlight (Cmd+Espace)\tenabled=%s\n' "$(/usr/libexec/PlistBuddy -c 'Print :AppleSymbolicHotKeys:64:enabled' "$HOME/Library/Preferences/com.apple.symbolichotkeys.plist" 2>/dev/null)"
  printf 'symbolichotkeys\t65 Recherche Finder (Cmd+Option+Espace)\tenabled=%s\n' "$(/usr/libexec/PlistBuddy -c 'Print :AppleSymbolicHotKeys:65:enabled' "$HOME/Library/Preferences/com.apple.symbolichotkeys.plist" 2>/dev/null)"
  printf 'dock\tapps\t%s\n' "$(defaults read com.apple.dock persistent-apps 2>/dev/null | awk -F'= ' '/"file-label"/{gsub(/;|"/,"",$2);print $2}' | tr '\n' ',' | sed 's/,$//')"
} > "$out/macos-defaults.tsv"
{
  echo "# Fichiers launchd tiers"; ls -1 "$HOME/Library/LaunchAgents" /Library/LaunchAgents /Library/LaunchDaemons 2>/dev/null
  echo; echo "# Extensions système"; systemextensionsctl list 2>/dev/null | awk -F'\t' '/\[activated/ {print $4" "$6}'
  echo; echo "# Overrides launchctl désactivés : nombre, hors FolderActionsDispatcher (détail : docs/debloat.md)"
  (launchctl print-disabled "gui/$(id -u)"; launchctl print-disabled system) 2>/dev/null | grep '=> disabled' | grep -vc 'FolderActionsDispatcher'
  echo "# com.apple.FolderActionsDispatcher : bascule lors d'appels osascript, sans incidence (non suivi)"
  echo; echo "# Ouverture à la session : non lisible sans admin (sfltool) — voir docs/demarrage-services.md"
} > "$out/startup.txt"
{
  printf 'outil\tversion\n'
  brew list --cask --versions | awk '{print "cask:"$1"\t"$2}'
  brew list --formula --versions | awk '{print "formula:"$1"\t"$2}'
  for b in "$HOME"/.nix-profile/bin/*; do n="${b##*/}"; case "$n" in fzf-share|fzf-tmux|atuin-server|atuin-nucleo-bench|ya) continue;; esac
    printf 'nix:%s\t%s\n' "$n" "$(readlink "$b" | sed -E 's#^/nix/store/[a-z0-9]+-##; s#/bin/.*##')"; done
  printf 'lix\t%s\n' "$(nix --version 2>/dev/null | awk '{print $NF}')"
  printf 'claude\t%s\n' "$(readlink "$HOME/.local/bin/claude" | sed 's#.*/##')"
  printf 'macOS\t%s (%s)\n' "$(sw_vers -productVersion)" "$(sw_vers -buildVersion)"
} > "$out/versions.tsv"
{
  printf 'action\traccourci\n'
  awk '/^\[\[hotkeys\]\]/{b=""; next} /^binding = /{b=$0; sub(/^binding = "/,"",b); sub(/"$/,"",b)} /^id = /{i=$0; sub(/^id = "/,"",i); sub(/"$/,"",i); if (b!="" && b!="Unassigned") print i"\t"b}' "$HOME/.config/omniwm/settings.toml" 2>/dev/null
} > "$out/omniwm-hotkeys.tsv"
echo "$out"
