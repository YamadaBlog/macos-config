# Home Manager + CLI

**Statut :** actif — testé
Version, provenance : voir `inventory/elements.tsv` et `docs/generated/versions.tsv`.

| | |
|---|---|
| Rôle / raison | Déclare les CLI (ripgrep, fzf, zoxide, bat, jq, fd, gh, delta, ast-grep, starship, yazi, lazygit, atuin, zsh) : un seul fournisseur par binaire. |
| Gestion (install, config, MAJ) | Installation, config et MAJ : Home Manager autonome (flake `home-manager/`). Le dépôt est la source. |
| Emplacements | `home-manager/{flake.nix,flake.lock,home.nix,shell.nix,profile.nix,identity.nix}` ; profil `~/.nix-profile` ; générations `~/.local/state/nix/profiles/home-manager-*`. |
| Dépendances | Lix ; nixpkgs-26.05-darwin ; home-manager release-26.05. |
| Permissions | — |
| Démarrage | Aucun service déclaré. |

## Paramètres
| Capturés (dans ce dépôt) | Reproductibles (script/commande) | Manuels (procédure) | Inconnus |
|---|---|---|---|
| — | Tout (flake + lock). | — | `gh` non authentifié ; `delta` non branché comme pager git. |

Fichiers capturés : aucun

## Mise à jour
`cd home-manager && nix flake update` puis `scripts/apply.sh home-manager --write` ; relire le diff du lock.

## Restauration
`home-manager generations` puis `<génération>/activate`.
