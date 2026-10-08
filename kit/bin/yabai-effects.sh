#!/bin/bash
# SPDX-License-Identifier: MIT
set -eu
task_script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
. "$task_script_dir/common.sh"
task_action="${1:-preview}"
case "$task_action" in
  preview) [ "$#" -eq 0 ] || exit 2;;
  --apply) [ "$#" -eq 1 ] || exit 2;;
  --restore) [ "$#" -eq 2 ] || exit 2;;
  *) printf '%s\n' 'Usage : yabai-effects.sh [--apply | --restore fichier.tsv]' >&2; exit 2;;
esac
printf '%s\n' 'Effets : inactive 96 %, active opaque, animation 0.16 s, ease_out_cubic.'
printf '%s\n' 'Prérequis manuels : scripting addition opérationnelle ; Screen Recording pour les animations.'
if [ "$task_action" = preview ]; then
 printf '%s\n' 'Aperçu. --apply sauvegarde les 5 valeurs courantes et tente leur restauration en cas d’échec.'; exit 0
fi
require_supported_mac
task_cli=/opt/homebrew/bin/yabai
[ -x "$task_cli" ] || { printf '%s\n' 'yabai absent.' >&2; exit 2; }
for task_process in OmniWM AeroSpace paneru Paneru; do
 if /usr/bin/pgrep -x "$task_process" >/dev/null 2>&1; then
  printf 'Quitter le gestionnaire actif : %s\n' "$task_process" >&2; exit 2
 fi
done
task_validate() {
 case "$1" in
  active_window_opacity|normal_window_opacity|window_animation_duration)
   case "$2" in ''|*[!0-9.]*) return 2;; esac;;
  window_opacity) case "$2" in on|off) :;; *) return 2;; esac;;
  window_animation_easing) case "$2" in ''|*[!a-z_]*) return 2;; esac;;
  *) return 2;;
 esac
}
task_restore() {
 task_restore_ok=0
 while IFS="$(printf '\t')" read -r task_key task_value; do
  "$task_cli" -m config "$task_key" "$task_value" || task_restore_ok=1
 done < "$task_snapshot"
 return "$task_restore_ok"
}
if [ "$task_action" = --restore ]; then
 task_snapshot="$2"
 [ -f "$task_snapshot" ] || { printf '%s\n' 'Sauvegarde absente.' >&2; exit 2; }
 task_seen=' '
 while IFS="$(printf '\t')" read -r task_key task_value; do
  task_validate "$task_key" "$task_value" || { printf '%s\n' 'Sauvegarde invalide.' >&2; exit 2; }
  case "$task_seen" in *" $task_key "*) printf '%s\n' 'Clé dupliquée.' >&2; exit 2;; esac
  task_seen="$task_seen$task_key "
 done < "$task_snapshot"
 for task_key in active_window_opacity normal_window_opacity window_opacity window_animation_easing window_animation_duration; do
  case "$task_seen" in *" $task_key "*) :;; *) printf '%s\n' 'Sauvegarde incomplète.' >&2; exit 2;; esac
 done
 task_restore
 printf '%s\n' 'Valeurs restaurées pour l’instance courante.'; exit 0
fi
umask 077
task_state="$HOME/.local/state/macos-poweruser-backups"
/bin/mkdir -p "$task_state"
task_snapshot="$(/usr/bin/mktemp "$task_state/yabai-effects.XXXXXX")"
for task_key in active_window_opacity normal_window_opacity window_opacity window_animation_easing window_animation_duration; do
 task_value="$("$task_cli" -m config "$task_key")"
 task_validate "$task_key" "$task_value" || { printf '%s\n' 'Valeur courante inattendue ; aucune modification appliquée.' >&2; exit 2; }
 printf '%s\t%s\n' "$task_key" "$task_value" >> "$task_snapshot"
done
task_on_error() {
 trap - EXIT INT TERM
 printf '%s\n' 'Échec ou interruption ; tentative de restauration des valeurs sauvegardées.' >&2
 task_restore || printf 'Restauration partielle : conserver %s et vérifier yabai.\n' "$task_snapshot" >&2
 exit 1
}
trap task_on_error EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
"$task_cli" -m config active_window_opacity 1.0
"$task_cli" -m config normal_window_opacity 0.96
"$task_cli" -m config window_opacity on
"$task_cli" -m config window_animation_easing ease_out_cubic
"$task_cli" -m config window_animation_duration 0.16
trap - EXIT INT TERM
printf 'Essai appliqué à l’instance courante ; sauvegarde : %s\n' "$task_snapshot"
printf 'Retour : bash bin/yabai-effects.sh --restore "%s"\n' "$task_snapshot"
printf '%s\n' 'Aucun changement de SIP, boot-args, sudoers ou yabairc.'
