#!/bin/bash
# SPDX-License-Identifier: MIT
set -u
printf '%s\n' 'Diagnostic macOS power user - lecture seule'
printf '%s\n' 'Aucun numero de serie, historique de presse-papiers, contenu de fichier ou secret IPC collecte.'
if [ "$(uname -s)" != "Darwin" ]; then
  printf '%s\n' 'Cet environnement n est pas macOS. Executer ce diagnostic sur ton Mac.'
  exit 2
fi
printf '\nmacOS : '; /usr/bin/sw_vers -productVersion
printf 'Architecture du processus : '; /usr/bin/uname -m
printf 'Materiel Apple Silicon : '; /usr/sbin/sysctl -n hw.optional.arm64 2>/dev/null || true
printf 'Modele : '; /usr/sbin/sysctl -n hw.model 2>/dev/null || true
printf '\nSIP :\n'; /usr/bin/csrutil status 2>/dev/null || true
printf '\nABI arm64e (presence du parametre seulement) :\n'
if /usr/sbin/nvram boot-args 2>/dev/null | /usr/bin/awk '{for(i=2;i<=NF;i++) if ($i == "-arm64e_preview_abi") found=1} END {exit !found}'; then
  printf '%s\n' 'Parametre -arm64e_preview_abi present.'
else printf '%s\n' 'Parametre absent ou lecture impossible ; comparer avec la procedure officielle yabai.'; fi
if [ -x /opt/homebrew/bin/yabai ]; then
  printf '\nVersion yabai installee :\n'; /opt/homebrew/bin/yabai --version
fi
printf '\nEcrans (champs techniques seulement) :\n'
/usr/sbin/system_profiler SPDisplaysDataType 2>/dev/null | /usr/bin/awk '/Chipset Model:|Resolution:|Main Display:|Mirror:|Online:|Connection Type:/ {print}'
printf '\nGestionnaires actifs (noms uniquement) :\n'
for task_process in OmniWM paneru Paneru AeroSpace yabai skhd Rectangle; do
  if /usr/bin/pgrep -x "$task_process" >/dev/null 2>&1; then printf '%s\n' "$task_process"; fi
done
if [ -x /opt/homebrew/bin/brew ]; then
  printf '\nHomebrew natif :\n'; /opt/homebrew/bin/brew --version
  printf 'Prefixe : '; /opt/homebrew/bin/brew --prefix
  printf '\nCasks selectionnes deja installes :\n'
  /opt/homebrew/bin/brew list --cask --versions 2>/dev/null | /usr/bin/awk '$1 ~ /^(omniwm|ghostty|neru|hammerspoon|raycast|bettertouchtool|stats|bunch|maccy|quicksilver|swiftbar|monitorcontrol|typewhisper|localsend|lulu|syntax-highlight|hotkeyclash)$/ {print}'
else printf '\n%s\n' 'Homebrew natif absent de /opt/homebrew.'; fi
printf '\nConfigurations presentes (contenu non lu) :\n'
task_xdg_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
for task_file in "$task_xdg_dir/omniwm/settings.toml" "$task_xdg_dir/ghostty/config.ghostty" "$task_xdg_dir/ghostty/config" "$task_xdg_dir/neru/config.toml" "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty" "$HOME/Library/Application Support/com.mitchellh.ghostty/config" "$HOME/.hammerspoon/init.lua"; do
  if [ -f "$task_file" ]; then printf '%s\n' "present : $task_file"; fi
done
printf '\n%s\n' 'Verifier les permissions dans Reglages Systeme et les diagnostics de chaque app.'
printf '%s\n' 'Le script ne lit pas la base TCC et ne valide pas le comportement des fenetres.'
