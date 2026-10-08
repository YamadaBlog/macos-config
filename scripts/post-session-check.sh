#!/bin/bash
# Contrôle après ouverture de session / réveil / redémarrage (lecture seule).
echo "== Instances (attendu : 1 chacun)"
for p in OmniWM neru Hammerspoon Stats Raycast; do printf '  %-12s %s\n' "$p" "$(pgrep -x "$p" | wc -l | tr -d ' ')"; done
echo "== Agents"; launchctl list | grep 'nix-community.home' | awk '{print "  "$3" pid="$1" dernier_code="$2}'
echo "== OmniWM"; printf '  ipc: '; /opt/homebrew/bin/omniwmctl ping 2>&1
printf '  bureaux: '; /opt/homebrew/bin/omniwmctl query workspaces --format tsv 2>/dev/null | awk -F'\t' 'NR>1 && NR<6{printf "%s ", $2}'; echo
echo "== Neru"; /opt/homebrew/bin/neru status 2>&1 | grep -E 'Status|Mode' | sed 's/^/  /'
echo "== Hammerspoon"; ( /Applications/Hammerspoon.app/Contents/Frameworks/hs/hs -c 'print("  ipc ok, accessibilité="..tostring(hs.accessibilityState()))' & p=$!; sleep 6; kill $p 2>/dev/null ) 2>/dev/null
echo "== Lix"; printf '  '; /nix/var/nix/profiles/default/bin/nix --version 2>&1 | head -1
echo "== Journaux"; ls -la "$HOME/Library/Logs/macos-config/" | awk 'NR>1 && $1 !~ /^l/ && $NF !~ /^\.\.?$/{print "  "$5" "$NF}'
echo "== Conformité"; "$HOME/dev/macos-config/scripts/verify.sh" >/tmp/verify-session.txt 2>&1; echo "  verify.sh code=$? (détail : /tmp/verify-session.txt)"
uptime | sed 's/^/== Uptime : /'
