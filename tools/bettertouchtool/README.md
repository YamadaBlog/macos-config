# BetterTouchTool

**Statut :** désinstallé le 2026-10-08 (`brew uninstall --cask bettertouchtool`, sans `--zap`) — données et préférences résiduelles conservées ; autorisations TCC résiduelles à supprimer
Version, provenance : voir `inventory/elements.tsv` et `docs/generated/versions.tsv`.

| | |
|---|---|
| Rôle / raison | Essai pour des gestes additionnels ; abandonné faute de geste libre utile (voir docs/decisions.md). |
| Gestion (install, config, MAJ) | Installation : cask. MAJ : intégrée. |
| Emplacements | Privé : `~/Library/Application Support/BetterTouchTool/` ; extensions installées avec l'app : widgets, menu contextuel Finder, extension Safari. |
| Dépendances | — |
| Permissions | Accessibilité, AppleEvents, Bluetooth accordées (à retirer si désinstallé). |
| Démarrage | Aucun (ni LaunchAgent, ni élément d'ouverture vérifié). |

## Paramètres
| Capturés (dans ce dépôt) | Reproductibles (script/commande) | Manuels (procédure) | Inconnus |
|---|---|---|---|
| — | — | Rien à exporter (aucun geste configuré). | — |

Fichiers capturés : aucun

## Mise à jour
—

## Restauration
Désinstaller : `brew uninstall --cask bettertouchtool` puis retirer ses autorisations dans Réglages > Confidentialité.
