# Hammerspoon

**Statut :** actif — testé (contextes 12/12, Hyper+P)
Version, provenance : voir `inventory/elements.tsv` et `docs/generated/versions.tsv`.

| | |
|---|---|
| Rôle / raison | Contextes Focus / Web / Messages / Atelier : bureau OmniWM puis ressources ; CLI `hs` pour tests. |
| Gestion (install, config, MAJ) | Installation : cask. Config : fichiers Lua. MAJ : intégrée. |
| Emplacements | `~/.hammerspoon/{init,poweruser,poweruser-backend,poweruser-projects}.lua` ↔ `tools/hammerspoon/config/`. `Spoons/` vide. |
| Dépendances | OmniWM IPC ; `/opt/homebrew/bin/omniwmctl`. |
| Permissions | Accessibilité (accordée). |
| Démarrage | LaunchAgent HM `org.nix-community.home.hammerspoon`. |

## Paramètres
| Capturés (dans ce dépôt) | Reproductibles (script/commande) | Manuels (procédure) | Inconnus |
|---|---|---|---|
| Tous les fichiers. | — | — | — |

Fichiers capturés : `config/init.lua`, `config/poweruser-backend.lua`, `config/poweruser-projects.lua`, `config/poweruser.lua`

## Mise à jour
Auto ; recharger la config.

## Restauration
`scripts/apply.sh hammerspoon --write` ; dossier inexistant avant le déploiement.
