# Restauration (retour arrière)

Sauvegardes privées : `~/.local/state/macos-power-user-deploy/backups/` (hors Git). Journal : `.../journal.txt`.

| Changement | Retour arrière |
|---|---|
| Shell HM | `rm ~/.zshrc ~/.zshenv ~/.zprofile; mv ~/.zshrc.pre-hm ~/.zshrc; mv ~/.zprofile.pre-hm ~/.zprofile` |
| Génération HM | `home-manager generations` puis `<chemin de la génération>/activate` |
| Paquet CLI | le retirer de `home-manager/home.nix`, `home-manager switch --flake ~/dev/macos-config/home-manager#mac` |
| Lix | `/nix/nix-installer uninstall` (ne jamais `rm -rf /nix`) |
| App Homebrew | quitter l'app, retirer son démarrage, `brew uninstall --cask <app>` ; config dans `tools/<app>/config/` |
| Config d'une app | `cp tools/<app>/config/<fichier> <chemin vivant>` (voir chaque `tools/<app>/README.md`) |
| Neru | défaut d'origine : `backups/neru-config.default.toml` |
| Spaces | `defaults delete com.apple.dock mru-spaces; killall Dock` |
| Domaine de préférences | `defaults import <domaine> backups/00-initial/<domaine>.plist` |

Les générations Nix ne sauvegardent ni données ni permissions. **Configurer Time Machine** reste en attente.
