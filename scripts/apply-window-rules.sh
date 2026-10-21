#!/bin/bash
# Put restored windows back on their workspace after login (or any time): OmniWM applies an app rule
# ("Safari -> Web") only to an app's FIRST window, so windows an app restores at launch (Safari's last session,
# Ghostty's saved windows) land on the active workspace. this script fixes all of
# them (it does not move windows already tracked, so each misplaced window is moved). Waits for OmniWM and for the window count to settle (apps restoring), then applies the rules of every app
# that has an assignToWorkspace rule in ~/.config/omniwm/settings.toml. Safe to run again at any time.
set -u
ctl="$HOME/.local/bin/omniwmctl"
settings="$HOME/.config/omniwm/settings.toml"
log() { printf '%s %s\n' "$(date '+%F %T')" "$*"; }

for _ in $(seq 60); do "$ctl" ping >/dev/null 2>&1 && break; sleep 2; done
"$ctl" ping >/dev/null 2>&1 || { log "OmniWM not answering, nothing done"; exit 0; }

count() { "$ctl" query windows --format json 2>/dev/null | python3 -c 'import json,sys
try: print(len(json.load(sys.stdin)["result"]["payload"]["windows"]))
except Exception: print(-1)'; }
last=-2; stable=0
for _ in $(seq 45); do   # up to ~90 s; settled = same count 3 times in a row (6 s)
  n=$(count)
  if [ "$n" = "$last" ]; then stable=$((stable + 1)); else stable=0; last=$n; fi
  [ "$stable" -ge 3 ] && break
  sleep 2
done

# Each tiled window of an app with an assignToWorkspace rule that sits on another workspace is moved there
# (`rule apply` only re-evaluates rules; it does not move windows that are already tracked).
moves=$(python3 - "$settings" "$("$ctl" query windows --format json)" "$("$ctl" query workspaces --format json)" <<'PY2'
import json, re, sys
rules = {}
for block in open(sys.argv[1]).read().split("[[appRules]]")[1:]:
    b = re.search(r'bundleId = "([^"]+)"', block); w = re.search(r'assignToWorkspace = "([^"]+)"', block)
    if b and w: rules[b.group(1)] = w.group(1)
spaces = json.loads(sys.argv[3])["result"]["payload"]["workspaces"]
number = {}
for ws in spaces:
    for key in ("displayName", "rawName"):
        if ws.get(key): number[ws[key]] = ws.get("number")
for w in json.loads(sys.argv[2])["result"]["payload"]["windows"]:
    want = rules.get(w["app"].get("bundleId"))
    if not want or w.get("mode") != "tiling" or number.get(want) is None: continue
    if w["workspace"]["number"] != number[want]:
        print(w["id"], number[want], w["app"]["name"])
PY2
)
while read -r id ws app; do
  [ -n "$id" ] || continue
  "$ctl" window move-to-workspace "$id" "$ws" >/dev/null 2>&1 && log "$app window moved to workspace $ws" || log "could not move $app window"
  sleep 0.5
done <<< "$moves"
log "done ($last windows)"
