#!/bin/bash
# SPDX-License-Identifier: MIT
# Lecture seule : sorties sélectionnées. Rediriger vers un journal privé si conservées.
set -u
if [ "$#" -ne 0 ]; then printf '%s\n' 'Usage : bash bin/ops-preflight.sh (lecture seule)' >&2; exit 2; fi
if [ "$(/usr/bin/uname -s)" != Darwin ]; then printf '%s\n' 'Cible non macOS : aucun déploiement à exécuter ici.' >&2; exit 2; fi
printf '%s\n' 'PRÉVOL OPS — lecture seule ; ne certifie ni TCC ni le fonctionnement des apps.'
printf 'macOS : '; /usr/bin/sw_vers -productVersion
printf 'Build : '; /usr/bin/sw_vers -buildVersion
printf 'Architecture processus : '; /usr/bin/uname -m
printf 'Apple Silicon : '; /usr/sbin/sysctl -n hw.optional.arm64 2>/dev/null || true
printf 'Compte court : '; /usr/bin/id -un
printf '\n%s\n' 'Exécutables trouvés (origines PATH) :'
for task_command in nix home-manager brew rg fzf zoxide bat jq starship atuin yazi lazygit omniwmctl paneru yabai; do
 command -v "$task_command" || true
done
if command -v nix >/dev/null 2>&1; then nix --version; fi
if [ -x /opt/homebrew/bin/brew ]; then
 HOMEBREW_NO_AUTO_UPDATE=1 /opt/homebrew/bin/brew --version
 HOMEBREW_NO_AUTO_UPDATE=1 /opt/homebrew/bin/brew --prefix
fi
printf '\n%s\n' 'Overrides launchctl (ils ne reconstituent pas tout le debloat) :'
/usr/bin/launchctl print-disabled "gui/$(/usr/bin/id -u)" 2>/dev/null || true
/usr/bin/launchctl print-disabled system 2>/dev/null || true
printf '\n%s\n' 'Permissions, launchd tiers, fichiers ciblés et tests natifs : vérifier séparément.'
