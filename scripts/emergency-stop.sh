#!/bin/bash
# Arrête OmniWM, Neru et Hammerspoon SANS relance automatique (jusqu'à la prochaine ouverture de session
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin
# ou jusqu'à scripts/emergency-start.sh). Ne touche à aucune configuration.
uid="$(id -u)"
for a in neru omniwm hammerspoon; do
  launchctl bootout "gui/$uid/org.nix-community.home.$a" 2>/dev/null && echo "agent $a déchargé"
done
osascript -e 'quit app "OmniWM"' -e 'quit app "Hammerspoon"' 2>/dev/null
sleep 2
for p in OmniWM Hammerspoon neru; do pkill -x "$p" 2>/dev/null && echo "$p forcé"; done
for p in OmniWM Hammerspoon neru; do pgrep -x "$p" >/dev/null && echo "ENCORE ACTIF : $p" || echo "arrêté : $p"; done
