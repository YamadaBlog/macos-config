#!/bin/bash
# macOS settings this setup depends on, declared once (desired state).
#   scripts/macos-defaults.sh            preview: current vs wanted, writes nothing (exit 1 if any differ)
#   scripts/macos-defaults.sh --write    back up the current values to a restore script, then apply
# The restore script (printed at the end) puts back every value it changed, including "absent".
# Why each gesture value: docs/omniwm.md "Gestures"; macOS must not own 3-finger swipes (OmniWM does)
# nor the 4-finger up swipe (OmniWM Overview), otherwise Mission Control opens behind the Overview.
. "$(dirname "$0")/lib.sh"
write=0; [ "${1:-}" = --write ] && write=1
# domain | key | type | value     ("-currentHost" prefix = per-host global domain)
WANTED='
com.apple.dock|autohide|bool|true
com.apple.dock|tilesize|int|43
com.apple.dock|orientation|string|left
com.apple.dock|show-recents|bool|false
com.apple.dock|magnification|bool|false
com.apple.dock|mru-spaces|bool|false
com.apple.dock|showMissionControlGestureEnabled|bool|false
com.apple.dock|showAppExposeGestureEnabled|bool|false
com.apple.finder|ShowPathbar|bool|true
com.apple.finder|ShowStatusBar|bool|true
com.apple.finder|FXPreferredViewStyle|string|icnv
NSGlobalDomain|AppleShowAllExtensions|bool|true
NSGlobalDomain|AppleInterfaceStyle|string|Dark
NSGlobalDomain|_HIHideMenuBar|bool|true
NSGlobalDomain|KeyRepeat|int|2
NSGlobalDomain|InitialKeyRepeat|int|15
NSGlobalDomain|com.apple.swipescrolldirection|bool|true
com.apple.WindowManager|GloballyEnabled|bool|false
com.apple.AppleMultitouchTrackpad|Clicking|bool|true
com.apple.AppleMultitouchTrackpad|TrackpadThreeFingerDrag|bool|false
com.apple.AppleMultitouchTrackpad|TrackpadThreeFingerHorizSwipeGesture|int|0
com.apple.AppleMultitouchTrackpad|TrackpadThreeFingerVertSwipeGesture|int|0
com.apple.AppleMultitouchTrackpad|TrackpadFourFingerHorizSwipeGesture|int|0
com.apple.AppleMultitouchTrackpad|TrackpadFourFingerVertSwipeGesture|int|0
com.apple.driver.AppleBluetoothMultitouch.trackpad|TrackpadThreeFingerHorizSwipeGesture|int|0
com.apple.driver.AppleBluetoothMultitouch.trackpad|TrackpadThreeFingerVertSwipeGesture|int|0
com.apple.driver.AppleBluetoothMultitouch.trackpad|TrackpadFourFingerHorizSwipeGesture|int|0
com.apple.driver.AppleBluetoothMultitouch.trackpad|TrackpadFourFingerVertSwipeGesture|int|0
-currentHost NSGlobalDomain|com.apple.trackpad.threeFingerHorizSwipeGesture|int|0
-currentHost NSGlobalDomain|com.apple.trackpad.threeFingerVertSwipeGesture|int|0
-currentHost NSGlobalDomain|com.apple.trackpad.fourFingerVertSwipeGesture|int|0
com.barut.OmniWM|OverviewHideWorkspaceLabels|bool|true
com.barut.OmniWM|OverviewHideSearchBar|bool|true
'
norm() { case "$1|$2" in bool\|true|bool\|1) echo 1;; bool\|false|bool\|0) echo 0;; *) echo "$2";; esac; }
restore="$STATE/backups/macos-defaults-$(date +%Y%m%d-%H%M%S).restore.sh"
diff=0; changed=0
[ "$write" = 1 ] && { mkdir -p "$(dirname "$restore")"; echo '#!/bin/bash' > "$restore"; }
while IFS='|' read -r dom key type val; do
  [ -n "$dom" ] || continue
  host=""; case "$dom" in "-currentHost "*) host="-currentHost"; dom="${dom#-currentHost }";; esac
  # shellcheck disable=SC2086  # $host is empty or one flag
  cur="$(defaults $host read "$dom" "$key" 2>/dev/null)" || cur="(absent)"
  want="$(norm "$type" "$val")"
  [ "$(norm "$type" "$cur")" = "$want" ] && continue
  diff=1; printf '  %-58s now=%-10s want=%s\n' "${host:+$host }$dom $key" "$cur" "$val"
  [ "$write" = 1 ] || continue
  if [ "$cur" = "(absent)" ]; then echo "defaults $host delete '$dom' '$key'" >> "$restore"
  else echo "defaults $host write '$dom' '$key' -$type '$cur'" >> "$restore"; fi
  # shellcheck disable=SC2086
  defaults $host write "$dom" "$key" "-$type" "$val"; changed=1
done <<< "$WANTED"
if [ "$diff" = 0 ]; then echo "macOS settings: all as wanted."; exit 0; fi
if [ "$write" = 0 ]; then echo "Preview only (--write to apply, with a restore script)."; exit 1; fi
if [ "$changed" = 1 ]; then
  killall Dock Finder SystemUIServer 2>/dev/null || true
  /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u 2>/dev/null || true
  chmod +x "$restore"; echo "Applied. Restore: bash $restore  (then log out/in for trackpad settings)"
fi
