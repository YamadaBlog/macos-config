#!/bin/bash
# SPDX-License-Identifier: MIT
set -eu
task_script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
task_kit_dir="$(CDPATH= cd -- "$task_script_dir/.." && pwd)"
. "$task_script_dir/common.sh"
task_apply=0
if [ "${1:-}" = "--apply" ]; then task_apply=1; shift; fi
if [ "$#" -eq 0 ] || [ "${1:-}" = "--list" ]; then
  printf '%s\n' 'Modules disponibles (aucune installation effectuee) :'
  for task_manifest in "$task_kit_dir"/manifests/Brewfile.*; do
    task_name="${task_manifest##*/Brewfile.}"
    printf '\n%s\n' "$task_name"
    /usr/bin/head -n 1 "$task_manifest"
  done
  printf '\n%s\n' 'Usage : bash bin/install-stage.sh core'
  printf '%s\n' 'Appliquer : bash bin/install-stage.sh --apply core'
  exit 0
fi
if [ "$#" -ne 1 ]; then printf '%s\n' 'Un seul module a la fois.' >&2; exit 2; fi
task_stage="$1"
case "$task_stage" in ''|*[!a-z0-9-]*) printf '%s\n' 'Nom de module invalide.' >&2; exit 2;; esac
task_manifest="$task_kit_dir/manifests/Brewfile.$task_stage"
if [ ! -f "$task_manifest" ]; then printf '%s\n' 'Module inconnu.' >&2; exit 2; fi
printf '\nModule : %s\n' "$task_stage"
/bin/cat "$task_manifest"
printf '\nCommande prevue : /opt/homebrew/bin/brew bundle install --no-upgrade --file=%s\n' "$task_manifest"
if [ "$task_apply" -eq 0 ]; then
  printf '%s\n' 'Apercu termine. Ajoute --apply pour installer ce module sur ton Mac.'
  exit 0
fi
require_supported_mac
if [ ! -x /opt/homebrew/bin/brew ]; then
  printf '%s\n' 'Homebrew natif introuvable. Installer depuis https://brew.sh puis reprendre.' >&2
  exit 2
fi
if [ "$(/opt/homebrew/bin/brew --prefix)" != "/opt/homebrew" ]; then
  printf '%s\n' 'Prefixe Homebrew inattendu ; verifier le diagnostic avant installation.' >&2
  exit 2
fi
if [ "$task_stage" = "core" ] && /usr/bin/pgrep -x OmniWM >/dev/null 2>&1; then
  printf '%s\n' 'Quitte OmniWM avant de remplacer ou verifier son bundle.' >&2
  exit 2
fi
if [ "$task_stage" = "core-yabai" ] && /usr/bin/pgrep -x yabai >/dev/null 2>&1; then
  printf '%s\n' 'Arrete yabai avant de remplacer ou verifier son binaire.' >&2
  exit 2
fi
if [ "$task_stage" = "core-paneru" ] && ( /usr/bin/pgrep -x paneru >/dev/null 2>&1 || /usr/bin/pgrep -x Paneru >/dev/null 2>&1 ); then
  printf '%s\n' 'Arrête Paneru avant de remplacer son binaire.' >&2
  exit 2
fi
# --no-upgrade limite les mises a jour ; Homebrew peut encore actualiser une dependance necessaire.
# Aucune desinstallation, activation de service ou copie de configuration dans cette commande.
/opt/homebrew/bin/brew bundle install --no-upgrade --file="$task_manifest"
printf '\n%s\n' 'Module installe. Ouvre les apps manuellement, puis applique les tests du plan.'
