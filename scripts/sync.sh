#!/bin/bash
# Point d'entrée unique (compatibilité). Voir docs/synchronisation.md.
#   sync.sh discover | verify [--hm] | capture [--accept] | apply <id> [--write]
#   (anciens alias : --check = verify, --capture = capture)
d="$(dirname "$0")"; cmd="${1:-}"; shift 2>/dev/null
case "$cmd" in
  discover) exec "$d/discover.sh" "$@";;
  verify|--check) exec "$d/verify.sh" "$@";;
  capture|--capture) exec "$d/capture.sh" "$@";;
  apply) exec "$d/apply.sh" "$@";;
  *) sed -n '2,5p' "$0"; exit 2;;
esac
