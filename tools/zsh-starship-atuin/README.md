# Zsh, Starship, Atuin

**Statut :** actif — testé
Version, provenance : voir `inventory/elements.tsv` et `docs/generated/versions.tsv`.

| | |
|---|---|
| Rôle / raison | Shell interactif, prompt, historique Ctrl-R local. |
| Gestion (install, config, MAJ) | Home Manager (`home-manager/shell.nix`). Shell de connexion : `/bin/zsh` (Apple). |
| Emplacements | Générés (liens vers le store, ne pas éditer) : `~/.zshrc`, `~/.zshenv`, `~/.zprofile`, `~/.config/starship.toml`, `~/.config/atuin/config.toml`. Privé : `~/.zsh_history`, `~/.zsh_sessions`, `~/.local/share/atuin`. |
| Dépendances | Home Manager ; hooks repris : `brew shellenv` (profileExtra), `~/.local/bin` (sessionPath, requis par Claude Code). |
| Permissions | — |
| Démarrage | — |

## Paramètres
| Capturés (dans ce dépôt) | Reproductibles (script/commande) | Manuels (procédure) | Inconnus |
|---|---|---|---|
| — | Tout via `shell.nix`. | — | — |

Fichiers capturés : aucun

## Mise à jour
Comme Home Manager.

## Restauration
`rm ~/.zshrc ~/.zshenv ~/.zprofile; mv ~/.zshrc.pre-hm ~/.zshrc; mv ~/.zprofile.pre-hm ~/.zprofile`.
