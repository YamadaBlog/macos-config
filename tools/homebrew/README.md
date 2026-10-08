# Homebrew

**Statut :** actif — testé
Version, provenance : voir `inventory/elements.tsv` et `docs/generated/versions.tsv`.

| | |
|---|---|
| Rôle / raison | Gestionnaire des apps GUI (casks) ; btop/htop préexistants. |
| Gestion (install, config, MAJ) | Installation : brew.sh. Liste : `homebrew/Brewfile` (généré par capture). MAJ : brew. |
| Emplacements | `/opt/homebrew`, `~/.homebrew/trust.json` (confiance du tap tiers), `homebrew/Brewfile`, `homebrew/modules/` (modules du kit). |
| Dépendances | Xcode CLT. |
| Permissions | Admin pour certains casks. |
| Démarrage | — |

## Paramètres
| Capturés (dans ce dépôt) | Reproductibles (script/commande) | Manuels (procédure) | Inconnus |
|---|---|---|---|
| `homebrew/Brewfile`. | `brew bundle install --file=homebrew/Brewfile`. | — | — |

Fichiers capturés : aucun

## Mise à jour
`brew update && brew upgrade` (casks auto_updates : par l'app) puis capture.

## Restauration
`brew uninstall --cask <app>` ; pas de downgrade garanti.
