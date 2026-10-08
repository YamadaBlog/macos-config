# Neru

**Statut :** actif — testé (S : 4 apps, 9/9 modes)
Version, provenance : voir `inventory/elements.tsv` et `docs/generated/versions.tsv`.

| | |
|---|---|
| Rôle / raison | Navigation clavier : hints, grille, défilement (Hyper+N/G/S). |
| Gestion (install, config, MAJ) | Installation : cask (tap `y3owk1n/tap`). Config : fichier. MAJ : brew. |
| Emplacements | `~/.config/neru/config.toml` ↔ `tools/neru/config/config.toml`. Journal : `~/Library/Logs/macos-config/neru.log`. |
| Dépendances | — |
| Permissions | Accessibilité (accordée, TCC). |
| Démarrage | LaunchAgent HM `org.nix-community.home.neru` : `neru launch`, KeepAlive si arrêt anormal, ThrottleInterval 30 s ; un Quitter/SIGTERM (code 0) n'est pas relancé. Lancement direct obligatoire (voir docs/recuperation.md, incident TCC). |

## Paramètres
| Capturés (dans ce dépôt) | Reproductibles (script/commande) | Manuels (procédure) | Inconnus |
|---|---|---|---|
| Config complète. | — | — | Arrêt du 2026-10-08 14:15:29 : assertion libdispatch interne à Neru (`Block was expected to execute on queue com.apple.main-thread`), déclencheur inconnu ; aucun rapport de plantage ; à signaler au mainteneur si récidive. Consulter : `/usr/bin/log show --predicate 'process == "neru"' --last 1h` (pas `log` sous zsh). |

Fichiers capturés : `config/config.toml`

## Mise à jour
`brew upgrade --cask neru` ; `neru config validate`.

## Restauration
Récupération : `launchctl kickstart -k gui/$(id -u)/org.nix-community.home.neru` ; config : `scripts/apply.sh neru --write`.
