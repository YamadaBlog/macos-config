#!/bin/bash
# SPDX-License-Identifier: MIT
set -eu
task_script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
. "$task_script_dir/common.sh"
task_apply=0
if [ "${1:-}" = "--apply" ] && [ "$#" -eq 1 ]; then task_apply=1
elif [ "$#" -gt 0 ]; then printf '%s\n' 'Usage : bash bin/backup-configs.sh [--apply]' >&2; exit 2; fi
task_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
task_backup_root="$HOME/.local/state/macos-poweruser-backups"
task_backup_stamp="$(date +%Y%m%d-%H%M%S)-$$"
printf 'Destination : %s/%s\n' "$task_backup_root" "$task_backup_stamp"
printf '%s\n' 'Sauvegarde partielle de fichiers sélectionnés ; pas une sauvegarde du Mac. Les fichiers shell peuvent contenir des secrets : conserver ces copies privées.'
if [ "$task_apply" -eq 1 ]; then
  require_supported_mac
  umask 077
  /bin/mkdir -p "$task_backup_root/$task_backup_stamp"
fi
task_copy() {
  task_source="$1"; task_label="$2"
  if [ -f "$task_source" ]; then
    printf '%s -> %s\n' "$task_source" "$task_label"
    if [ "$task_apply" -eq 1 ]; then /bin/cp -p "$task_source" "$task_backup_root/$task_backup_stamp/$task_label"; fi
  fi
}
task_copy "$task_config_dir/omniwm/settings.toml" omniwm-settings.toml
task_copy "$task_config_dir/neru/config.toml" neru-config.toml
task_copy "$task_config_dir/neru/config.override.toml" neru-config.override.toml
task_copy "$task_config_dir/ghostty/config.ghostty" ghostty-xdg-config.ghostty
task_copy "$task_config_dir/ghostty/config" ghostty-xdg-legacy-config
task_copy "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty" ghostty-macos-config.ghostty
task_copy "$HOME/Library/Application Support/com.mitchellh.ghostty/config" ghostty-macos-legacy-config
task_copy "$HOME/.hammerspoon/init.lua" hammerspoon-init.lua
task_copy "$HOME/.hammerspoon/poweruser.lua" hammerspoon-poweruser.lua
task_copy "$HOME/.hammerspoon/poweruser-projects.lua" hammerspoon-projects.lua
task_copy "$HOME/.hammerspoon/poweruser-backend.lua" hammerspoon-backend.lua
task_copy "$HOME/.hammerspoon/poweruser-yabai-keys.lua" hammerspoon-yabai-keys.lua
task_copy "$task_config_dir/paneru/paneru.toml" paneru.toml
task_copy "$task_config_dir/paneru/paneru.lua" paneru.lua
task_copy "$HOME/.zshrc" zshrc
task_copy "$HOME/.zshenv" zshenv
task_copy "$HOME/.zprofile" zprofile
task_copy "$task_config_dir/zsh/.zshrc" zsh-xdg-zshrc
task_copy "$task_config_dir/starship.toml" starship.toml
task_copy "$task_config_dir/yabai/yabairc" yabai-xdg-yabairc
task_copy "$HOME/.yabairc" yabai-legacy-yabairc
task_copy "$task_config_dir/borders/bordersrc" borders-bordersrc
task_copy "$task_config_dir/sketchybar/sketchybarrc" sketchybar-sketchybarrc
if [ "$task_apply" -eq 0 ]; then printf '%s\n' 'Apercu seulement ; ajouter --apply sur ton Mac pour effectuer les copies.'; fi
