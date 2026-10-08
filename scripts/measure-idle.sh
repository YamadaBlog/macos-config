#!/bin/bash
# Mesure de consommation au repos des outils résidents.
#   scripts/measure-idle.sh [durée_s=600] [pas_s=5]
# Méthode : ps -o %cpu (moyenne décroissante du noyau, pas un instantané) et RSS, un échantillon par pas ;
# sortie TSV privée + résumé (moyenne, médiane, p95, max). Conditions à noter : secteur/batterie, apps ouvertes.
dur="${1:-600}"; step="${2:-5}"
out="$HOME/.local/state/macos-power-user-deploy/logs/cpu-$(date +%Y%m%d-%H%M).tsv"
printf 'ts\tproc\tcpu\trss_ko\n' > "$out"
end=$(( $(date +%s) + dur ))
while [ "$(date +%s)" -lt "$end" ]; do
  ts=$(date +%s)
  for p in Stats OmniWM neru Hammerspoon Raycast; do
    pid=$(pgrep -x "$p" | head -1); [ -n "$pid" ] || continue
    ps -o %cpu=,rss= -p "$pid" | LC_ALL=C awk -v t="$ts" -v n="$p" '{gsub(",",".",$1); print t"\t"n"\t"$1"\t"$2}' >> "$out"
  done
  sleep "$step"
done
"$(dirname "$0")/measure-summary.sh" "$out"
