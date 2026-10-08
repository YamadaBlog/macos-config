# btop

**Statut :** installé (préexistant)
Version, provenance : voir `inventory/elements.tsv` et `docs/generated/versions.tsv`.

| | |
|---|---|
| Rôle / raison | Moniteur processus terminal. |
| Gestion (install, config, MAJ) | brew. |
| Emplacements | `~/.config/btop/btop.conf` ↔ `tools/btop/config/btop.conf` ; thèmes locaux non copiés. |
| Dépendances | ncurses |
| Permissions | — |
| Démarrage | — |

## Paramètres
| Capturés (dans ce dépôt) | Reproductibles (script/commande) | Manuels (procédure) | Inconnus |
|---|---|---|---|
| btop.conf | — | — | — |

Fichiers capturés : `config/btop.conf`

## Mise à jour
`brew upgrade btop`.

## Restauration
`scripts/apply.sh btop --write`.

## Depuis le 2026-10-08
Fourni par Nix (`programs.btop`), thème Stylix ; version Homebrew désinstallée. Ancienne config (identique aux valeurs par défaut) : `~/.config/btop/btop.conf.pre-hm`.
