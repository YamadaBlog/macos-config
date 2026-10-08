# Lix (Nix)

**Statut :** actif — testé
Version, provenance : voir `inventory/elements.tsv` et `docs/generated/versions.tsv`.

| | |
|---|---|
| Rôle / raison | Daemon et CLI Nix ; base de Home Manager. Choisi car aucun Nix n'existait (Lix = installateur officiel retenu par le kit). |
| Gestion (install, config, MAJ) | Installation : installateur Lix (admin). Config : installateur. MAJ : procédure Lix. |
| Emplacements | `/nix` (volume APFS chiffré « Nix Store »), `/etc/nix/nix.conf`, `/nix/receipt.json`, `/etc/zshrc` `/etc/zshenv` `/etc/bashrc` (hooks). |
| Dépendances | macOS ; aucun autre gestionnaire Nix (ne pas superposer Determinate/nix officiel). |
| Permissions | Mot de passe admin (installation). |
| Démarrage | launchd : `org.nixos.nix-daemon`, `org.nixos.darwin-store`, `systems.lix.nix-installer.nix-hook`. |

## Paramètres
| Capturés (dans ce dépôt) | Reproductibles (script/commande) | Manuels (procédure) | Inconnus |
|---|---|---|---|
| — | Réinstallation : `curl -sSf -L https://install.lix.systems/lix | sh -s -- install` (flakes : oui). | — | — |

Fichiers capturés : aucun

## Mise à jour
Suivre https://lix.systems/install/ (section upgrade).

## Restauration
`/nix/nix-installer uninstall`. Jamais `rm -rf /nix`.
