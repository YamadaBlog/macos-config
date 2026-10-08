# Recherche : espace sous l'encoche et thème unifié (2026-10-08)

## 1. Espace en haut de l'écran (encoche)

### Mécanisme (vérifié)
- Écran intégré à encoche : `frame` 2177×1407 pt, `visibleFrame` 2177×1367 (40 pt exclus), **même barre des menus masquée**.
- Apple : `NSScreen.safeAreaInsets.top` = zone couverte par le boîtier de la caméra
  ([doc](https://developer.apple.com/documentation/appkit/nsscreen/safeareainsets.md)).
- Placer une fenêtre au-dessus du bas de l'encoche via l'API Accessibilité : impossible en pratique — le mainteneur
  d'AeroSpace : « macOS doesn't allow to put arbitrary windows above the notch's bottom line »
  ([AeroSpace #176](https://github.com/nikitabobko/AeroSpace/issues/176), fermée) ; macOS repousse les fenêtres
  ([forum Apple 728504](https://developer.apple.com/forums/thread/728504)). Seules des apps elles-mêmes (plein écran
  « simple », fenêtres sans titre) y parviennent ; un gestionnaire de fenêtres ne peut pas l'imposer.
- OmniWM : marge haute = `max(0, top − hauteur barre)` depuis le bord physique, valeur négative ramenée à 0
  ([OmniWM #612](https://github.com/OmniNull/OmniWM/issues/612), « working as designed ») — confirmé sur ce poste.
  Ne pas utiliser `[[monitorGapOverrides]]` : invalide tout `settings.toml` ([#830](https://github.com/OmniNull/OmniWM/issues/830), ouverte).

### Solutions comparées
| Solution | macOS 26 | Maintenance | Résultat réel | Contraintes / risques |
|---|---|---|---|---|
| Marge OmniWM `top = 48` (appliquée) | ✅ | OmniWM actif | **testé** : 8 px sous l'encoche, marges 8 px côtés/bas conservées | bande de 40 pt vide (fond d'écran) |
| **Résolution 16:10 « sous l'encoche » 2177×1360 @2x** | ✅ mode natif proposé par macOS | aucune (réglage système) | **testé ici 10 s puis annulé** : `frame = visibleFrame = 2177×1360`, `hasNotch = false` ; la bande de l'encoche est **éteinte** (noire, se confond avec le cadre) | hauteur utile 1360 − 16 = 1344 pt contre 1351 aujourd'hui (**−7 pt**) ; il faut `top = 8` dans ce mode (sinon 48 pt de marge) ; la barre des menus est dessinée sous la bande noire quand elle apparaît |
| TopNotch / Forehead / LiuHai | partiel | TopNotch installé, non lancé | cosmétique : peint la bande en noir | ne change pas la géométrie |
| Patch d'OmniWM / autre WM (AeroSpace, yabai…) | — | — | **aucun** projet trouvé qui place des fenêtres sous l'encoche | limite macOS, pas du WM |
| Modifier SIP/SSV/WindowServer | — | — | non étudié | hors périmètre du poste |

**Conclusion** : aucune méthode ne fait gagner de pixels utiles au-dessus de l'encoche. Le seul moyen de **supprimer la bande
vide visible** est la résolution 16:10 2177×1360 : la bande devient du cadre noir, les fenêtres démarrent à 8 pt du haut
de la nouvelle zone, au prix de 7 pt de hauteur utile.
Mise en œuvre si retenue (réversible) : Réglages Système > Affichages > « Afficher toutes les résolutions » > 2177×1360
(ou `hs.screen.mainScreen():setMode(2177,1360,2,120,8)`), puis `[gaps.outer] top = 8` et
`singleWindowFit = "2161x1336"` (1360 − 16 − 8). Retour : mode 2177×1407, `top = 48`, `2161x1351`.

## 2. Thème unifié depuis le fond d'écran

### Options
| Projet | macOS | Piloté par Nix | Génère depuis l'image | État |
|---|---|---|---|---|
| **[Stylix](https://github.com/nix-community/stylix)** `release-26.05` | ✅ en Home Manager autonome (`stylix.homeModules.stylix`) ; n'agit pas sur l'apparence macOS | ✅ | ✅ `stylix.image` + `polarity` (palette base16, algorithme génétique, au build) | branche vérifiée (révision 078d8f7, 2026-09-26) ; génération sur aarch64-darwin **à tester** |
| nix-colors (`colorSchemeFromPicture`) | ✅ | ✅ | ✅ (via flavours, non maintenu) | peu actif — écarté |
| tinted-theming / tinty | ✅ | partiel | ❌ (schémas existants) | actif ; source de schémas |
| matugen / wallust | ✅ | ❌ (exécution) | ✅ | actifs ; hors Nix |
| pywal | — | — | — | non maintenu |

Cibles Stylix utiles ici : ghostty, starship, bat, fzf, lazygit, btop, yazi (à confirmer), jankyborders (non utilisé).
Linux uniquement (à ignorer) : gtk, qt, gnome, kde, hyprland, sway, waybar, rofi, plymouth…

### Applications hors Stylix
| Application | Méthode |
|---|---|
| Ghostty | `programs.ghostty` (HM) avec `package = pkgs.ghostty-bin` (1.3.1, aarch64-darwin vérifié) ou `package = null` en gardant le cask |
| OmniWM | couleurs (bordure, barre) écrites dans `settings.toml` par `apply-registry.py` à partir de la palette exportée — pas de prise de possession du fichier par HM (OmniWM le réécrit) |
| Neru | section `[theme.dark]` remplie depuis la palette (même méthode) |
| Hammerspoon | `colors.lua` généré par HM, chargé par les modules |
| Raycast | thème personnalisé = probablement payant (Pro) : manuel |
| Accent macOS | `AppleAccentColor` : 8 couleurs fixes → la plus proche de base0D |
| Fond d'écran | défini depuis le dépôt (`wallpapers/`) à l'activation |

### Architecture proposée (non appliquée)
```
home-manager/flake.nix     + input stylix (release-26.05, follows nixpkgs/home-manager)
home-manager/theme.nix     stylix.{enable,image=../wallpapers/actuel.jpg,polarity="dark",autoEnable=false}
                           targets.{ghostty,starship,bat,fzf,lazygit,btop,yazi}.enable = true
                           home.file palette.json (export base16) → lu par apply-registry.py et un script Neru
wallpapers/actuel.jpg      source unique
scripts/theme-apply.sh     après « apply home-manager » : OmniWM, Neru, Hammerspoon, fond d'écran, accent
```
Changer de fond d'écran = remplacer `wallpapers/actuel.jpg` → `scripts/apply.sh home-manager --write` → `scripts/theme-apply.sh`.
Risques : Stylix rend les configs ciblées en lecture seule (gérées par Nix) ; palette terne si le fond est peu coloré
(figer alors un `base16Scheme`) ; Ghostty passerait sous Home Manager (migration de `~/.config/ghostty`).

## 3. Rétro-ingénierie de la zone de l'encoche (recherche du 2026-10-08)
- Aucun travail public ne montre le placement d'une **fenêtre d'une autre app** dans la bande de l'encoche sur macOS 26.
- API privées SkyLight (`SLSMoveWindow`…) : n'agissent en principe que sur les fenêtres de sa propre connexion ; agir sur
  celles des autres exige une injection type scripting addition yabai (Dock.app). Aucune preuve que cela marche sous l'encoche
  sur macOS 26 ; demande ouverte côté yabai ([#1934](https://github.com/koekeishiya/yabai/issues/1934)) ; risque de plantage
  de WindowServer et rupture à chaque mise à jour. **Non retenu.**
- macOS 26 durcit la zone (analyse SaneBar, [NOTCH_MOVE_LIMITATION](https://raw.githubusercontent.com/sane-apps/SaneBar/main/docs/NOTCH_MOVE_LIMITATION.md)).
- Ce qui marche : une app qui étend **sa propre** fenêtre (NotchDrop, BoringNotch…, et les terminaux en plein écran non natif).
  Ghostty : `macos-non-native-fullscreen = true` couvre toute la dalle, encoche comprise (variantes `visible-menu`, `padded-notch`) ;
  le gestionnaire de fenêtres peut contraindre la fenêtre ([yabai #2216](https://github.com/koekeishiya/yabai/issues/2216)) → à
  tester avec OmniWM si un plein écran Ghostty sur toute la dalle est voulu (non appliqué).

## 4. Rétro-ingénierie, 2ᵉ passe : qui bloque vraiment ? (tests sur ce poste, 2026-10-08 18:5x)
| Test | Résultat |
|---|---|
| Fenêtres Finder, Ghostty, Safari rendues flottantes (hors OmniWM), placées via l'API Accessibilité à y = 5 | **ramenées à y = 40 immédiatement** |
| Fenêtre titrée créée par Hammerspoon dans son propre processus, placée à y = 0 | ramenée à y = 40 |
| Même fenêtre sans barre de titre | ramenée à y = 40 |
| Calque `hs.canvas` (panneau de niveau élevé, même processus) à y = 0 | **accepté : y = 0**, visible devant la bande de l'encoche (capture) |

**Conclusion** : WindowServer accepte des fenêtres dans la bande ; le recadrage est fait **par chaque app**, dans AppKit
(`-[NSWindow constrainFrameRect:toScreen:]`, qui contraint sous la barre des menus et la zone de l'encoche).
Sources : exemple Apple FullScreenWindow (surcharge de `constrainFrameRect` pour dépasser la barre),
[cocoa-dev 2002](https://lists.apple.com/archives/cocoa-dev/2002/Feb/msg00339.html), Emacs `nsterm.m` ; Electron et Tk ajoutent leurs
propres blocages ([Electron 0cc1ebc](https://ayakael.net/mirrors/electron/commit/0cc1ebc021c28cd2148bca388af60e8dcb5d8e66)).
Aucun tweak public « sans contrainte de barre des menus » trouvé ; [forum Apple 699136](https://developer.apple.com/forums/thread/699136) sans réponse.

### Solutions possibles, de la plus sûre à la plus intrusive
| Voie | Portée | Prérequis | Risques |
|---|---|---|---|
| Ghostty `macos-non-native-fullscreen` | Ghostty seul, plein écran | aucun | OmniWM peut le contraindre ; texte du haut derrière la caméra |
| **Injection ciblée** : dylib qui remplace `constrainFrameRect` (renvoie le cadre demandé), chargée dans une **copie re-signée** d'une app tierce (`DYLD_INSERT_LIBRARIES` + entitlements `allow-dyld-environment-variables`, `disable-library-validation`) | une app tierce à la fois (Ghostty, Discord*) | SIP déjà désactivé ; Xcode CLT (présent) ; **aucun boot-arg** | copie hors mises à jour ; crash possible de l'app ; *Electron peut avoir son propre blocage ; **impossible pour Safari** (binaire système) |
| Ammonia (injection dans toutes les apps) | toutes | boot-arg `-arm64e_preview_abi` (**hors périmètre**) ; dépôt archivé le 2026-06-02 | système, mises à jour |
| yabai + scripting addition (`SLSMoveWindow` depuis Dock) | toutes, si l'app ne recontraint pas | second WM, chargement root, sudoers | hors périmètre (un seul WM) |

## 5. Test d'injection (2026-10-08 19:10) — RÉUSSI sur une copie de Ghostty
Module `experiments/encoche/sansencoche.m` : remplace `-[NSWindow constrainFrameRect:toScreen:]` pour autoriser le haut de
l'écran **physique** (jamais au-delà des bords). Copie re-signée localement avec `allow-dyld-environment-variables` et
`disable-library-validation`, lancée avec `DYLD_INSERT_LIBRARIES` (piège : ne pas passer par `nohup`/`env`, binaires arm64e).

| Fenêtre flottante placée à y = 8 | Résultat |
|---|---|
| Copie de Ghostty avec module | **y = 8, stable** (capture : la fenêtre occupe la bande à côté de l'encoche) |
| Ghostty d'origine | y = 40 |

Limites établies :
- **Fenêtres en mosaïque** : OmniWM calcule ses cadres depuis `visibleFrame` (haut à 40) — il faut aussi **modifier OmniWM**
  (open source, Swift) pour qu'il utilise le cadre physique quand la barre des menus est masquée ; sans cela seul le flottant en profite.
- Une copie re-signée par app tierce ; pas de mise à jour automatique ; Safari et apps Apple impossibles ; Electron (Discord) non testé.
- Reproduire : `experiments/encoche/tester.sh`. Rien n'est installé de façon permanente.

## 6. Généralisation (décision du 2026-10-08)
- **Apps** : pas de mécanisme d'injection généralisé. Il exigerait de désactiver à l'échelle du système des protections de
  macOS (validation des signatures et des bibliothèques, hardened runtime), ce qui permettrait aussi à du code malveillant
  de s'injecter partout. Non retenu, même réversible. Alternatives sûres : options natives des apps (Ghostty
  `macos-non-native-fullscreen`), demandes aux éditeurs, retour à Apple (Feedback Assistant).
- **OmniWM** : option opt-in proposée (`experiments/omniwm-full-height/`) ; compilation et tests bloqués sans Xcode 27.
