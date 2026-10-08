#!/bin/bash
# Recharge et relance les agents arrêtés par emergency-stop.sh.
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin
uid="$(id -u)"
for a in omniwm hammerspoon neru; do
  f="$HOME/Library/LaunchAgents/org.nix-community.home.$a.plist"
  launchctl bootstrap "gui/$uid" "$f" 2>/dev/null || launchctl kickstart "gui/$uid/org.nix-community.home.$a"
done
for i in $(seq 15); do /opt/homebrew/bin/neru status >/dev/null 2>&1 && break; sleep 1; done
for p in OmniWM Hammerspoon neru; do printf '%s=%s ' "$p" "$(pgrep -x "$p" | wc -l | tr -d ' ')"; done; echo
/opt/homebrew/bin/omniwmctl ping 2>/dev/null; /opt/homebrew/bin/neru status 2>/dev/null | grep Status
