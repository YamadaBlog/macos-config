#!/bin/bash
# EXPERIMENTAL — reproduces the 2026-10-08 test: a COPY of Ghostty whose windows can rise into the notch
# band. Does not modify /Applications/Ghostty.app. Prerequisites: SIP disabled (already), Xcode CLT.
# Rollback: quit the copy and delete the working directory.
set -e
W="${TMPDIR:-/tmp}/encoche-test"; mkdir -p "$W"; A="$W/GhosttyEncoche.app"; D="$(cd "$(dirname "$0")" && pwd)"
clang -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX26.5.sdk -mmacosx-version-min=26.0 \
  -dynamiclib -fobjc-arc -framework AppKit -arch arm64 -o "$W/sansencoche.dylib" "$D/sansencoche.m"
codesign --force --sign - "$W/sansencoche.dylib"
rm -rf "$A"; ditto /Applications/Ghostty.app "$A"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.mitchellh.ghostty.encoche-test" -c "Set :CFBundleName GhosttyEncoche" "$A/Contents/Info.plist"
codesign -d --entitlements :- /Applications/Ghostty.app > "$W/ent.plist" 2>/dev/null
/usr/libexec/PlistBuddy -c "Add :com.apple.security.cs.allow-dyld-environment-variables bool true" \
  -c "Add :com.apple.security.cs.disable-library-validation bool true" "$W/ent.plist"
codesign --force --deep --sign - --entitlements "$W/ent.plist" "$A"
# Launch WITHOUT an intermediate program (otherwise dyld injects into nohup/env, arm64e binaries)
( export DYLD_INSERT_LIBRARIES="$W/sansencoche.dylib"; exec "$A/Contents/MacOS/ghostty" ) >"$W/run.log" 2>&1 &
echo "Copy launched; log: $W/run.log (should contain \"[sansencoche]\")."
