#!/bin/bash
# Stop OmniWM, Neru and Hammerspoon WITHOUT automatic restart (until the next login
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin
# or scripts/emergency-start.sh). Touches no configuration.
uid="$(id -u)"
for a in neru omniwm hammerspoon; do
  launchctl bootout "gui/$uid/org.nix-community.home.$a" 2>/dev/null && echo "agent $a unloaded"
done
osascript -e 'quit app "OmniWM"' -e 'quit app "Hammerspoon"' 2>/dev/null
sleep 2
for p in OmniWM Hammerspoon neru; do pkill -x "$p" 2>/dev/null && echo "$p killed"; done
for p in OmniWM Hammerspoon neru; do pgrep -x "$p" >/dev/null && echo "STILL RUNNING: $p" || echo "stopped: $p"; done
