#!/bin/bash
# DÉCOUVERTE (lecture seule) : liste normalisée de ce qui est installé sur le poste.
# Sortie : une clé par ligne (type:valeur). Utilisé par verify.sh pour la couverture.
# Périmètre : voir docs/inventaire.md (limites : App Store via _MASReceipt, pas de lecture
# des bases TCC/BTM, extensions Raycast chiffrées, contenus des apps non inspectés).
. "$(dirname "$0")/lib.sh"
shopt -s nullglob
{
for a in /Applications/*.app /Applications/*/*.app "$HOME"/Applications/*.app "$HOME"/Applications/*/*.app; do
  id="$(defaults read "$a/Contents/Info" CFBundleIdentifier 2>/dev/null)" || continue
  [ -n "$id" ] && echo "app:$id"
  [ -d "$a/Contents/_MASReceipt" ] && echo "mas:$id"
done
brew list --cask -1 2>/dev/null | sed 's/^/cask:/'
brew list --formula -1 2>/dev/null | sed 's/^/formula:/'
brew tap 2>/dev/null | sed 's/^/tap:/'
for b in "$HOME"/.nix-profile/bin/*; do echo "nixbin:${b##*/}"; done
for b in /nix/var/nix/profiles/default/bin/*; do echo "nixdefault:${b##*/}"; done
for b in "$HOME"/.local/bin/*; do echo "localbin:${b##*/}"; done
for b in /usr/local/bin/*; do echo "bin:$b"; done
pkgutil --pkgs 2>/dev/null | grep -v '^com\.apple\.' | sed 's/^/pkg:/'
for f in "$HOME"/Library/LaunchAgents/* /Library/LaunchAgents/* /Library/LaunchDaemons/*; do echo "launchd:${f##*/}"; done
systemextensionsctl list 2>/dev/null | awk -F'\t' '/\[activated/ {split($4,a," "); print "sysext:"a[1]}'
for d in "$HOME"/.config/*; do echo "config:${d##*/}"; done
for d in "$HOME"/.[!.]*; do echo "dot:${d##*/}"; done
for d in "$HOME"/*; do
  case "${d##*/}" in Desktop|Documents|Downloads|Library|Movies|Music|Pictures|Public|Applications) ;; *) echo "home:${d##*/}";; esac
done
for f in "$HOME"/Library/Fonts/* "$HOME"/Library/QuickLook/* /Library/QuickLook/* "$HOME"/Library/PreferencePanes/* /Library/PreferencePanes/* "$HOME"/Library/Services/*; do
  echo "plugin:${f#$HOME/}"
done
# Domaines de préférences tiers, dossiers Application Support, extensions d'apps
for f in "$HOME"/Library/Preferences/*.plist; do b="${f##*/}"; b="${b%.plist}"; case "$b" in com.apple.*|.GlobalPreferences*|loginwindow|ContextStoreAgent|pbs|diagnostics_agent|MobileMeAccounts|corespotlightd|familycircled|mbuseragent|sharedfilelistd|systemgroup.*|TokenBucketRateLimiter) ;; *) echo "pref:$b";; esac; done
for d in "$HOME"/Library/Application\ Support/*; do echo "appsupport:${d##*/}"; done
pluginkit -mA 2>/dev/null | grep -oE '[A-Za-z0-9._-]+\(' | tr -d '(' | grep -v '^com\.apple\.' | sed 's/^/appex:/'
crontab -l 2>/dev/null | grep -v '^#' | grep -q . && echo "cron:user"
} | sort -u
