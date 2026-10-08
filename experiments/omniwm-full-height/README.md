# OmniWM — option `gaps.fullHeightWhenMenuBarHidden`

État au 2026-10-08 21:30 : **implémentée, compilée, tests ciblés réussis, essayée sur le poste : effet NÉGATIF. Non publiée ; PR non recommandée en l'état.**
- Branche locale : `~/dev/omniwm`, branche `full-height-hidden-menu-bar`, commit `73d74cc6` sur `origin/main` (9943b9c2).
- Patch : `0001-fullHeightWhenMenuBarHidden.patch` (à appliquer avec `git am`).
- Proposition d'issue : `PROPOSITION-issue.md` (formulaire pré-rempli ouvert dans Safari ; publication par l'utilisateur).

## Changement
Option TOML `[gaps] fullHeightWhenMenuBarHidden` (booléen optionnel, défaut `false`, fichiers existants inchangés).
Si activée **et** barre des menus masquée (`_HIHideMenuBar`) : la marge haute est mesurée depuis le bord physique.
Fichiers : `MenuBarVisibility.swift` (nouveau, point d'injection pour les tests), `SettingsExport`, `CanonicalTOMLConfig`,
`GapSettings`, `ResolvedGapSettings`, clé du cache de mise en page (état de la barre), `buildLayoutFrames`, doc de référence.
Pas d'interface Réglages dans ce premier jet : le contrôle de localisation exige 20 langues traduites et relues.

## Vérifications
| Contrôle | Résultat |
|---|---|
| `make verify` (format, lint, build) | **OK** |
| Tests ciblés `GapSettingsTests` + `LayoutConfigurationCacheTests` (dont 3 nouveaux) | **38/38 OK** |
| Suite complète de référence (avant changement) | 5 158 tests, 7 échecs préexistants (gestes, Overview, barre masquée) |
| Suite complète avec le changement | **interrompue** : blocage à 20:20 puis gel du Mac, redémarrage 20:45 (voir ci-dessous) |
| Essai réel sur le poste (OmniWM Dev) | non fait |

## Incident du 2026-10-08 (suite complète)
La suite complète crée de vraies fenêtres/panneaux ; lancée sur le poste en usage, avec OmniWM réel actif, elle s'est bloquée
(dernier test démarré : `WindowCornerRadiiTests.testParserPreservesFourFractionalValues`) ; l'utilisateur a vu une fenêtre de
rectangles, puis le Mac a gelé (redémarrage forcé ; aucun rapport de panique). Cause exacte non établie.
**Règle** : ne pas lancer `swift test` complet sur le poste en usage ; seulement des tests ciblés (`--filter`), ou la suite
complète session fermée / OmniWM quitté / machine dédiée, ou laisser la CI du projet l'exécuter sur la PR.

## Reste à faire avant PR
1. Accord du mainteneur sur l'issue. 2. Suite complète dans un contexte sûr (CI du projet). 3. Essai réel avec OmniWM Dev
(`make run`), en sachant que la plupart des apps se recontraignent sous l'encoche. 4. Interface + traductions si souhaité.
Retour : rien n'est installé ; supprimer la branche (`git branch -D full-height-hidden-menu-bar`).

## Essai réel sur le poste (OmniWM Dev, build 73d74cc6, 2026-10-08 21:2x)
Réglages Dev : option activée, `outer.top = 8`, marges 8 px, barre des menus masquée.
| App | OmniWM demande | Résultat réel |
|---|---|---|
| Aperçu, Ghostty, Safari, Terminal (AppKit) | haut 8, bas 8 (pleine hauteur) | **haut 40, bas 0** |
| Discord (Electron) | idem | **haut 40, bas 0** |
Chaque app recale sa fenêtre sous l'encoche (`constrainFrameRect`) en la décalant vers le bas et en la rognant :
la marge basse est perdue. **L'option dégrade la mise en page de toutes les apps testées.**
Piège de mesure : les fenêtres d'un bureau caché sont garées au bord de l'écran ; mesurer sur le bureau courant.
Retour effectué : `make use-release` (OmniWM 0.7.6 officiel, marges 48/8 vérifiées).

## Conclusion
Une option côté OmniWM ne peut pas fonctionner seule : il faudrait que les apps cessent de se recontraindre (injection,
écartée pour raisons de sécurité). Prochaine étape possible : signaler ce constat (issue « information ») ou abandonner.

## Combinaison testée (2026-10-08 22:16) — RÉUSSIE pour une app coopérative
OmniWM Dev (option activée) + copie de Ghostty dont `constrainFrameRect` est neutralisé (`experiments/encoche/`) :
| Fenêtre en mosaïque sur Focus | Haut | Bas |
|---|---|---|
| copie de Ghostty | **8 pt du bord physique** | 8 |
| Ghostty officiel | 40 | 0 (dégradé) |
Il faut donc **les deux côtés** : OmniWM qui demande la pleine hauteur, et une app qui accepte de s'y placer.

## Recherche Ghostty (v1.3.1, code et doc officiels)
- Aucune option ne place une fenêtre normale sous l'encoche ; `macos-non-native-fullscreen` (`true`, `visible-menu`,
  `padded-notch`) ne concerne que le plein écran ; `window-position-x/y` est relatif à la zone visible et recalé.
- Pas de surcharge de `constrainFrameRect` ; `BaseTerminalController.swift` (l. 526-552) recale aussi dans `visibleFrame`.
- Aucun terminal trouvé (WezTerm, Alacritty, iTerm2, kitty) ne le fait hors plein écran.

## Piste durable (sans injection)
1. **Ghostty** (open source) : option propre, ex. `macos-window-avoid-notch = false`, qui surcharge `constrainFrameRect` dans sa
   fenêtre et ajuste `BaseTerminalController` ; contribution amont, ou compilation locale en attendant.
2. **OmniWM** : remplacer « pleine hauteur pour tout » par « pleine hauteur seulement pour les fenêtres qui l'acceptent » —
   détection du recalage (cadre relu plus bas que demandé) → cette fenêtre retombe sous l'encoche avec ses marges normales.
   Évite la dégradation constatée sur les autres apps.

## v2 — détection par fenêtre (2026-10-08, commit omniwm 99c89705)
Si une fenêtre placée dans la bande de l'encoche est relue collée au haut visible, elle est mémorisée
(`NotchBandRefusals`) et ses cadres sont raccourcis par le haut : 8 px sous l'encoche, marge du bas conservée.
CORRECTION : l'« essai réel » 48/8 n'est PAS valide. Après `make run`, OmniWM Dev (nouvelle signature) n'avait
plus l'Accessibilité (journal : TCCAccessRequest en boucle) et ne gérait aucune fenêtre ; les 48/8 relevés étaient
les positions laissées par la release. Essai à refaire après autorisation d'OmniWM Dev. Tests ciblés 95/95, make verify OK. Release rétablie après l'essai.
Limite : un identifiant de fenêtre réutilisé garde la marque (sans effet sauf si la nouvelle fenêtre coopérait).

## Ghostty `macos-window-avoid-notch` (2026-10-08)
Branche `avoid-notch-main` sur Ghostty main (Zig 0.16 requis : Zig 0.15.2 ne lie plus avec les SDK macOS 26.5+/27).
Compilé (nix shell zig_0_16 + gettext, Metal Toolchain téléchargé via xcodebuild). Copie d'essai
$TMPDIR/encoche-test/GhosttyNotch.app (com.mitchellh.ghostty.notch-test). Essai bloqué par le même problème d'Accessibilité.
