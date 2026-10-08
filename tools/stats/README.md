# Stats

**Statut :** actif — limité
Version, provenance : voir `inventory/elements.tsv` et `docs/generated/versions.tsv`.

| | |
|---|---|
| Rôle / raison | Moniteur barre de menus : CPU, RAM, Réseau (batterie/GPU/capteurs/disque désactivés). |
| Gestion (install, config, MAJ) | Installation : cask. Config : plist. MAJ : intégrée. |
| Emplacements | Domaine `eu.exelban.Stats` ↔ `tools/stats/config/eu.exelban.Stats.plist` (sans `remote_id`, sans clés volatiles). |
| Dépendances | — |
| Permissions | Accessibilité accordée à l'installation (non requise). |
| Démarrage | LaunchAgent Home Manager `org.nix-community.home.stats`. |

## Paramètres
| Capturés (dans ce dépôt) | Reproductibles (script/commande) | Manuels (procédure) | Inconnus |
|---|---|---|---|
| Plist nettoyé. | `defaults write eu.exelban.Stats <Module>_state -bool false`. | — | — |

Fichiers capturés : `config/eu.exelban.Stats.plist`

## Mise à jour
Auto.

## Restauration
Quitter ; `scripts/apply.sh stats --write` ; avant limitation : `backups/stats.pre-limite.plist`.
