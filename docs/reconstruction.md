# Reconstruire le poste (ordre des dépendances)

Statut de cette procédure : **évaluée/compilée, pas restaurée de bout en bout.** Vérifié le 2026-10-08 :
la flake Home Manager se construit depuis ce dépôt et produit exactement la génération active ;
`homebrew/Brewfile` correspond aux apps installées ; chaque config capturée est identique au poste.
Aucune réinstallation complète sur une machine vierge n'a été effectuée.

### Testé / non testé
| Élément | Statut |
|---|---|
| Build Home Manager depuis le dépôt = génération active | testé (`verify.sh --hm`) |
| Application + retour d'une config fichier (btop) et plist (TopNotch) ; réapplication sans changement | testé (S) |
| Agents de démarrage chargés et idempotents (`kickstart`) | testé (S) |
| `brew bundle install` sur Mac vierge | **non testé** (seulement `brew bundle check`) |
| Installation Lix + première activation HM sur compte vierge | **non testé** (fait une fois sur ce poste, avec migration manuelle) |
| Import des exports privés (Raycast, Lunar, Terminal) | **non testé** |
| Restauration Time Machine | **non testé** (aucune destination) |
| Permissions TCC sur nouveau Mac | manuel par nature |

| # | Étape | Dépend de | Commande / action | Vérification |
|---|---|---|---|---|
| 0 | Données | — | Restaurer Time Machine (non configuré à ce jour) ou copier `~/dev/macos-config` | dépôt présent |
| 1 | macOS + compte | — | macOS 26.x, compte `mao`, disposition « French » | `defaults read com.apple.HIToolbox AppleSelectedInputSources` |
| 2 | Xcode CLT | 1 | `xcode-select --install` | `git --version` |
| 3 | Homebrew | 2 | installateur https://brew.sh | `brew --prefix` = `/opt/homebrew` |
| 4 | Apps GUI | 3 | `brew bundle install --file=homebrew/Brewfile` (le tap tiers demande confiance) | `brew bundle check --file=homebrew/Brewfile` |
| 5 | Lix | 1 | `curl -sSf -L https://install.lix.systems/lix \| sh -s -- install` (mot de passe saisi par l'utilisateur ; flakes : oui) | nouveau terminal : `nix --version` |
| 6 | Claude Code | 1 | installateur natif officiel | `~/.local/bin/claude --version` |
| 7 | Home Manager | 5, 3 (brew shellenv), 6 (~/.local/bin) | déplacer `~/.zshrc`/`~/.zprofile` existants puis `scripts/apply.sh home-manager --write` | nouveau shell : `scripts/verify.sh --hm` |
| 8 | Configs d'apps | 4 | pour chaque id de `scripts/apply.sh --list` : `scripts/apply.sh <id> --write` (OmniWM, Stats, TopNotch : app quittée) | `scripts/verify.sh` |
| 9 | Permissions | 4 | `docs/permissions.md` (Accessibilité : OmniWM, Neru, Hammerspoon, BTT) | tests de `STATUS.md` |
| 10 | OmniWM | 8, 9 | vérifier `ipcEnabled = true` ; règles d'apps incluses dans `settings.toml` | `omniwmctl ping` ; `workspace focus-name Web` |
| 11 | Hammerspoon | 10 | config déjà copiée à l'étape 8 | `hs -c 'poweruser.launch("web")'` |
| 12 | Secrets et comptes | 4 | `docs/secrets.md` (Raycast .rayconfig, Tailscale, gh, Claude, Lunar) | connexions OK |
| 13 | Réglages macOS | 1 | `docs/macos.md` (mru-spaces ; valeurs de référence `docs/generated/macos-defaults.tsv`) | `scripts/verify.sh` (instantanés) |
| 14 | Démarrage | 7, 9 | inclus dans Home Manager (`startup.nix`) ; Raycast : Open at Login | après reconnexion : `pgrep -x OmniWM neru Hammerspoon Stats Raycast` |
| 15 | nix-darwin (optionnel) | 5, sauvegarde | `nix-darwin/README.txt` — non activé à ce jour | — |

Ne pas reproduire le debloat automatiquement : il est documenté (`docs/debloat.md`), pas prescrit.
