#!/bin/bash
# SPDX-License-Identifier: MIT
set -eu
task_script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
task_kit_dir="$(CDPATH= cd -- "$task_script_dir/.." && pwd)"
. "$task_script_dir/common.sh"
task_apply=0
if [ "${1:-}" = "--apply" ]; then task_apply=1; shift; fi
if [ "$#" -ne 1 ]; then printf '%s\n' 'Usage : bash bin/apply-theme.sh [--apply] glass|opaque' >&2; exit 2; fi
task_theme="$1"
case "$task_theme" in glass|opaque) ;; *) printf '%s\n' 'Theme inconnu.' >&2; exit 2;; esac
task_config_root="${XDG_CONFIG_HOME:-$HOME/.config}"
case "$task_config_root" in /*) ;; *) printf '%s\n' 'XDG_CONFIG_HOME doit etre absolu.' >&2; exit 2;; esac
task_target="$task_config_root/ghostty/config.ghostty"
task_source="$task_kit_dir/configs/ghostty-$task_theme.config.ghostty"
printf 'Theme : %s\nCible : %s\n' "$task_theme" "$task_target"
printf '%s\n' 'Le preset remplace la configuration cible apres sauvegarde ; le relire et fusionner tes reglages si necessaire.'
if [ "$task_apply" -eq 0 ]; then printf '%s\n' 'Apercu seulement ; ajouter --apply pour copier ce preset.'; exit 0; fi
require_supported_mac
# Refus des autres fichiers charges, pour ne pas masquer des preferences existantes.
for task_other in "$task_config_root/ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"; do
  if [ -f "$task_other" ]; then printf 'Autre configuration chargee : %s. Fusionner manuellement avant de reprendre.\n' "$task_other" >&2; exit 2; fi
done
if [ -L "$task_target" ]; then printf '%s\n' 'Cible symlink : modifier sa source declaree, pas le lien.' >&2; exit 2; fi
umask 077
task_theme_stamp="$(date +%Y%m%d-%H%M%S)-$$"
task_theme_backup="$HOME/.local/state/macos-poweruser-backups/$task_theme_stamp"
/bin/mkdir -p "$task_theme_backup" "$(dirname -- "$task_target")"
if [ -f "$task_target" ]; then /bin/cp -p "$task_target" "$task_theme_backup/ghostty-before.config.ghostty"
else printf '%s\n' 'Configuration inexistante avant application.' > "$task_theme_backup/ghostty-was-absent.txt"; fi
/bin/cp "$task_source" "$task_target"
printf 'Preset applique. Sauvegarde : %s\n' "$task_theme_backup"
printf '%s\n' 'Relancer Ghostty ; regler opacite et effet du Quake dans OmniWM.'
