#!/bin/bash
# Résumé d'un fichier produit par measure-idle.sh.
f="${1:?fichier tsv}"
echo "fichier : $f ; échantillons par outil : $(awk -F'\t' 'NR>1{n[$2]++} END{for(k in n){print n[k]; exit}}' "$f")"
printf '%-12s %8s %8s %8s %8s %10s\n' outil moy med p95 max rss_moy_Mo
for p in $(awk -F'\t' 'NR>1{print $2}' "$f" | sort -u); do
  awk -F'\t' -v p="$p" 'NR>1 && $2==p {print $3}' "$f" | sort -n > /tmp/.m.$$
  n=$(wc -l < /tmp/.m.$$ | tr -d " ")
  LC_ALL=C awk -v n="$n" '{a[NR]=$1; s+=$1} END{m=a[int((n+1)/2)]; p=a[int(n*0.95+0.999)]; printf "%8.2f %8.2f %8.2f %8.2f", s/n, m, p, a[n]}' /tmp/.m.$$ | xargs printf "%-12s %s %s %s %s" "$p"
  LC_ALL=C awk -F'\t' -v p="$p" 'NR>1 && $2==p {s+=$4; n++} END{printf " %10.0f\n", s/n/1024}' "$f"
done
rm -f /tmp/.m.$$
