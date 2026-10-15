#!/bin/bash
# Compare the macOS settings declared in home-manager/macos.nix with this Mac (read-only).
#   scripts/macos-defaults.sh          list every declared setting whose live value differs; exit 1 if any
#   scripts/macos-defaults.sh --write  apply them = activate Home Manager (scripts/apply.sh home-manager --write)
# Home Manager is the only writer (targets.darwin.defaults); rollback = previous generation (docs/recovery.md).
. "$(dirname "$0")/lib.sh"
if [ "${1:-}" = --write ]; then exec "$REPO/scripts/apply.sh" home-manager --write; fi
cd "$REPO/home-manager" || exit 2
attr='.#homeConfigurations.mac.config'
want="$(MACOS_CONFIG_REPO="$REPO" nix eval --impure --json "$attr.targets.darwin" \
  --apply 't: { d = t.defaults; h = t.currentHostDefaults; }' 2>/dev/null)" \
  || { echo "Cannot evaluate home-manager/macos.nix (nix eval failed)." >&2; exit 2; }
hot="$(grep -oE 'disabledHotkeys = \[[^]]*\]' "$REPO/home-manager/macos.nix" | tr -cd '0-9 ')"
python3 -I - "$want" "$hot" <<'PY'
import json, plistlib, subprocess, sys, os
want = json.loads(sys.argv[1]); hot = sys.argv[2].split()
def export(domain, host=False):
    cmd = ["defaults"] + (["-currentHost"] if host else []) + ["export", "-g" if domain == "NSGlobalDomain" else domain, "-"]
    out = subprocess.run(cmd, capture_output=True).stdout
    try: return plistlib.loads(out) if out else {}
    except Exception: return {}
def same(a, b):
    if isinstance(b, bool) or isinstance(a, bool): return bool(a) == bool(b) if a is not None else False
    if isinstance(b, float) or isinstance(a, float):
        try: return abs(float(a) - float(b)) < 1e-6
        except (TypeError, ValueError): return False
    return a == b
diff = 0
for host, table in ((False, want["d"]), (True, want["h"])):
    for dom, keys in table.items():
        live = export(dom, host)
        for k, v in keys.items():
            if v is None: continue   # option left unset (null): not managed
            cur = live.get(k)
            if not same(cur, v):
                diff += 1
                print(f"  {'-currentHost ' if host else ''}{dom} {k}: now={cur!r} want={v!r}")
p = os.path.expanduser("~/Library/Preferences/com.apple.symbolichotkeys.plist")
try: sk = plistlib.load(open(p, "rb")).get("AppleSymbolicHotKeys", {})
except Exception: sk = {}
for n in hot:
    if sk.get(n, {}).get("enabled", True):
        diff += 1; print(f"  symbolic hotkey {n}: enabled (want disabled)")
print("macOS settings: all as declared." if diff == 0 else
      f"{diff} setting(s) differ. Apply: scripts/macos-defaults.sh --write (then log out/in for trackpad settings).")
sys.exit(1 if diff else 0)
PY
