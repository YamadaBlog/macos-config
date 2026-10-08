# Mesures de consommation

## Session du 2026-10-08, 15:35–15:45
- **Méthode** : `scripts/measure-idle.sh 600 5` — `ps -o %cpu,rss` toutes les 5 s pendant 600 s (597 s réels), 118 échantillons par outil ;
  `%cpu` de `ps` est une moyenne décroissante calculée par le noyau, pas une valeur instantanée.
- **Conditions** : sur secteur (batterie en charge), Safari, Discord, Ghostty, Terminal et Finder ouverts ; l'assistant exécutait
  par moments des commandes légères (lecture de fichiers, git) — **pas un repos strict**.
- **Données brutes** (privées) : `~/.local/state/macos-power-user-deploy/logs/cpu-10min-1535.tsv`.

```
outil             moy      med      p95      max rss_moy_Mo
Hammerspoon  0.00 0.00 0.00 0.00        104
neru         0.01 0.00 0.10 0.30         67
OmniWM       0.06 0.00 0.50 1.20        121
Raycast      0.00 0.00 0.00 0.10        168
Stats        0.49 0.20 2.00 2.70        211
```
(% d'un cœur ; rss = mémoire résidente moyenne)

## Lecture
- Tous les outils résidents restent sous 0,1 % de CPU en moyenne sauf Stats (≈ 0,5 %, pics à 2–3 %), qui rafraîchit ses capteurs.
- Une seule session, au repos relatif : **ne permet pas de conclure** à une consommation optimale ni de chiffrer un effet sur l'autonomie.
- Relevé ponctuel antérieur (14:30, 5 × 2 s) : Stats ≈ 2 % avant limitation des modules — conditions différentes, non comparable.

## Pour aller plus loin (non fait)
Répéter `scripts/measure-idle.sh 1800 10` sur batterie, écran allumé, mêmes apps, avec et sans Stats quitté ;
comparer aussi `pmset -g log` (autonomie) sur plusieurs jours.
