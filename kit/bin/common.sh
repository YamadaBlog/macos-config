#!/bin/bash
# SPDX-License-Identifier: MIT
require_supported_mac() {
  if [ "$(uname -s)" != "Darwin" ]; then
    printf '%s\n' 'Application refusee : ce kit cible ton Mac, pas cet environnement.' >&2
    return 2
  fi
  task_major="$(/usr/bin/sw_vers -productVersion | /usr/bin/cut -d. -f1)"
  case "$task_major" in ''|*[!0-9]*) printf '%s\n' 'Version macOS indeterminee.' >&2; return 2;; esac
  if [ "$task_major" -ne 26 ] && [ "$task_major" -ne 27 ]; then
    printf '%s\n' 'Ce kit cible macOS 26/27 ; réauditer avant une autre version majeure. Ce contrôle ne certifie pas la compatibilité de chaque app.' >&2
    return 2
  fi
  if [ "$(/usr/sbin/sysctl -n hw.optional.arm64 2>/dev/null || true)" != "1" ]; then
    printf '%s\n' 'Ce profil exige un Mac Apple Silicon.' >&2
    return 2
  fi
}
