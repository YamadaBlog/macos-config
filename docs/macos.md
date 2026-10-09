# Réglages macOS

Valeurs réelles relevées à chaque capture : `docs/generated/macos-defaults.tsv`
(Dock, coins actifs, Spaces, Finder, apparence, clavier, trackpad, barre de menus, captures, disposition).
Sauvegarde de chaque domaine avant toute modification : `~/.local/state/macos-power-user-deploy/backups/00-initial/<domaine>.plist` (privé).

## Modifiés par le déploiement
| Réglage | Valeur | Avant | Retour |
|---|---|---|---|
| Spaces : réorganiser selon l'usage | `com.apple.dock mru-spaces = 0` | absent (= oui) | `defaults delete com.apple.dock mru-spaces; killall Dock` |
| Shell | Home Manager | `~/.zshrc`, `~/.zprofile` simples | `docs/restauration.md` |
| `/etc/zshrc`, `/etc/zshenv`, `/etc/bashrc` | hooks Lix | versions Apple | désinstallation Lix |
| Finder : barre de chemin | `com.apple.finder ShowPathbar = 1` | absent | `defaults delete com.apple.finder ShowPathbar; killall Finder` |
| Finder : barre d'état | `com.apple.finder ShowStatusBar = 1` | absent | `defaults delete com.apple.finder ShowStatusBar; killall Finder` |
| Extensions de fichiers visibles | `NSGlobalDomain AppleShowAllExtensions = 1` | absent | `defaults delete NSGlobalDomain AppleShowAllExtensions; killall Finder` |
| Finder : favori `~/dev` | barre latérale (Ctrl+Cmd+T sur le dossier) | absent | clic droit sur « dev » > Retirer de la barre latérale |
| Spotlight : Cmd+Espace | `symbolichotkeys` 64 désactivé (Raycast l'utilise) | activé | `defaults import com.apple.symbolichotkeys backups/symbolichotkeys.pre-raycast.plist` puis `activateSettings -u` |
| Barre OmniWM / bordures | voir `tools/omniwm` | désactivées | `backups/omniwm-*/settings.toml` |
| Barre des menus : masquage automatique « Toujours » | `osascript -e 'tell application "System Events" to tell dock preferences to set autohide menu bar to true'` (écrire seulement `AutoHideMenuBarOption`/`_HIHideMenuBar` ne s'applique pas en direct) | jamais masquée (`AutoHideMenuBarOption = 3`, `_HIHideMenuBar = 0`) | même commande avec `false` |
| Raccourcis Ctrl+←/→, Ctrl+Shift+←/→ (espaces macOS) | symbolichotkeys 79–82 désactivés (repris par OmniWM) | activés | `defaults import com.apple.symbolichotkeys backups/navig-175131/symbolichotkeys.plist` puis `activateSettings -u` |
| Trackpad : 4 doigts horizontal (espaces macOS) | `TrackpadFourFingerHorizSwipeGesture = 0` (2 domaines trackpad) ; OmniWM prend ce geste pour ses bureaux | 2 | `defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerHorizSwipeGesture -int 2` (idem `com.apple.driver.AppleBluetoothMultitouch.trackpad`) puis `activateSettings -u` |

## Observés (préexistants, non modifiés)
| Domaine | Réglage |
|---|---|
| Dock | masqué auto, taille 43, à gauche, sans récents, sans agrandissement ; apps : Safari, Notes, Réglages |
| Coins actifs | bas droit = 14 (Note rapide) |
| Spaces | Spaces distincts par écran (défaut) |
| Apparence | sombre ; accentuation par défaut ; barre de menus visible |
| Clavier | disposition French (AZERTY) ; KeyRepeat 2 / InitialKeyRepeat 15 |
| Trackpad | défilement naturel ; toucher pour cliquer ; 3 doigts : vertical = Mission Control, horizontal = **libre** (OmniWM) ; 4 doigts : Spaces/Mission Control |
| Finder | vue par défaut ; voir « Modifiés » pour les barres et extensions |
| Affichage | écran XDR intégré 3456×2234 ; Lunar et TopNotch installés, non lancés actuellement |
| Barre de menus | apps tierces lancées (2026-10-08) : Stats, Raycast, OmniWM, Neru, Hammerspoon, BTT, Tailscale ; Lunar et TopNotch installés mais **non lancés** |
| Sécurité | SIP désactivé, SSV scellé — **hors périmètre** |

## Prévu, non appliqué
`nix-darwin/darwin.nix` : mêmes valeurs Finder que celles appliquées aujourd'hui en préférences utilisateur, Dock (autohide, taille 43 = valeur réelle, mru-spaces off).
Conditions : Time Machine configuré, build + audit de l'activation (`nix-darwin/README.txt`).
Pour un réglage ponctuel sans nix-darwin : `defaults write …` puis capture et ligne dans `CHANGELOG.md`.

## Bande en haut de l'écran (encoche)
L'écran intégré a une encoche (`hasNotch: true`) : macOS exclut 40 px en haut de la zone utilisable (`visibleFrame` 2177×1367 sur 1407),
même barre des menus masquée — le centre de cette bande est occupé par la caméra. Ce n'est ni une marge ni la barre OmniWM
(marges extérieures 0, `edgeGaps = false`, barre désactivée, `reserveLayoutSpace = false`). Aucun réglage OmniWM ne place les
fenêtres sous l'encoche (marge haute négative testée : ignorée) ; le contenu y serait masqué.
Conséquence : sur cet écran, masquer la barre des menus **ne libère aucun espace** pour les fenêtres ; la bande reste vide.
Marge haute retenue : `outer.top = 48` (la doc OmniWM la mesure depuis le bord physique) → 8 px sous la limite de l'encoche, comme les autres côtés. Terminal.app peut laisser quelques px supplémentaires (taille par caractères).

## Stage Manager: must stay OFF (2026-10-09)
Stage Manager (`com.apple.WindowManager GloballyEnabled`) fights OmniWM: on workspace switches the screen stayed empty for seconds
and windows piled up as thumbnails on the right edge. Turn off: `defaults write com.apple.WindowManager GloballyEnabled -bool false; killall WindowManager`.
It can be turned on by accident from Control Center; `scripts/verify.sh` now flags it (snapshot `docs/generated/macos-defaults.tsv`).
