# Journal des changements du poste

Format : date — changement — fichiers/réglages — retour arrière. Détails et preuves : journal privé.

## 2026-10-08
- Prévol ; debloat préexistant identifié (mac-os-debloat 0.13.2, dev-minimal). Aucun changement.
- `com.apple.dock mru-spaces = false` (absent avant) — retour : `defaults delete com.apple.dock mru-spaces; killall Dock`.
- Homebrew : ghostty, omniwm, raycast, neru (tap y3owk1n), hammerspoon, stats, bettertouchtool (essai).
- Ghostty : `~/.config/ghostty/config.ghostty` (thème Bleu Nuit glass) — créé.
- Neru : config 1.57 générée + hotkeys Hyper+N/G/S (défauts Cmd+Shift retirés) — défaut sauvegardé.
- Lix 2.95.2 installé par l'utilisateur (modifie `/etc/zshrc`, `/etc/zshenv`, `/etc/bashrc`).
- Home Manager : CLI, shell (migration brew shellenv + ~/.local/bin), Atuin local, Yazi, Lazygit, fd, gh, delta, ast-grep.
  Anciens `~/.zshrc`, `~/.zprofile` → `*.pre-hm`.
- Hammerspoon : `~/.hammerspoon/` créé (contextes) ; `hs.ipc` ajouté ; contextes activés après tests ;
  Focus = bureau seul ; Atelier → `~/dev/macos-config`.
- Dépôt de référence `~/dev/macos-config` (clone de `~/Projects/macos-config`, conservé).
- OmniWM : `ipcEnabled = true` ; Hyper = Ctrl+Option+Cmd ; 43 raccourcis Option désassignés ou remappés en Hyper
  (`tools/omniwm/apply-registry.py`) ; W AZERTY déclaré `Z` (positions QWERTY) ; bureaux 1–4 étiquetés
  Focus/Web/Messages/Atelier (`displayName`) ; règles Safari → Web, Discord → Messages.
  Retour : `~/.local/state/macos-power-user-deploy/backups/omniwm-*/settings.toml` (OmniWM quitté).
- Scripts discover/capture/apply/verify ; inventaire structuré ; fiches pour 22 outils.

## 2026-10-08 (après-midi)
- Démarrage : LaunchAgents Home Manager (`home-manager/startup.nix`) pour OmniWM, Hammerspoon, Stats, Neru
  (KeepAlive sur arrêt anormal + `~/Library/Logs/macos-config/neru.log`). Retour : retirer l'import de `startup.nix`, `scripts/apply.sh home-manager --write`.
- Raycast : raccourci ⌘ Espace (était ⌥ Espace) ; Spotlight retiré de Cmd+Espace (symbolichotkeys 64) ;
  quicklinks « Dépôt macos-config », « Recherche web » ; snippet `;bjr`. Retour : `backups/symbolichotkeys.pre-raycast.plist`.
- Finder : barre de chemin, barre d'état, extensions visibles, favori `~/dev` (clés absentes avant).
- OmniWM : bordure 2 px #91baff, barre de bureaux transparente avec espace réservé, bureaux vides masqués.
- Stats : modules réduits à CPU, RAM, Réseau. Retour : `backups/stats.pre-limite.plist`.
- BetterTouchTool : écarté, arrêté (aucun démarrage). Décisions des modules : `docs/decisions.md`.
- `apply.sh` : correction du retour plist (`defaults import` fusionnait ; désormais `delete` + `import`), testé.
- Découverte élargie (prefs, Application Support, extensions d'apps) ; vérification des permissions TCC.
- Exports privés hors Git : Lunar (avec/sans clé), Terminal.

## 2026-10-08 (fin d'après-midi)
- Neru : test arrêt volontaire (SIGTERM → non relancé) et panne persistante (relance toutes les ThrottleInterval s, sans plafond).
  ThrottleInterval porté de 10 à 30 s. **Incident** : un lanceur bash de plafonnement (15:31) a fait réinitialiser par Neru
  son Accessibilité et une autorisation a été accordée à `/nix/store/…-bash` (15:32) ; lanceur retiré, Neru réautorisé (15:33),
  autorisation `bash` **à retirer** (docs/nettoyage.md N4).
- Rotation des journaux (`logrotate`, 6 h, 1 Mo, une archive), testée.
- `scripts/emergency-stop.sh` / `emergency-start.sh` (testés), `scripts/post-session-check.sh`, `docs/recuperation.md`.
- Correction : les lectures du journal unifié faites avec `log` sous zsh étaient invalides (commande interne). Avec `/usr/bin/log` :
  arrêt de Neru à 14:15:29 sur une assertion libdispatch interne. Services de diagnostic du debloat documentés.
- OmniWM : bordure et barre retrouvées désactivées à 15:34 (origine non établie) — en attente de ta préférence.
- `verify.sh` : correction de l'affichage des écarts TCC.

## 2026-10-08 (soir)
- Entrée TCC `bash` identifiée (`/nix/store/hr5jdf535nm54yq3jzkyx8k9a0m3hwql-bash-5.3p9/bin/bash`), désactivée par l'utilisateur 15:55 ; Neru vérifié.
- OmniWM bordure/barre : désactivation de 15:34 examinée (journal), cycle rejoué sans reproduction, état trouvé restauré ; décision demandée.
- Rotation : passage à « copier la fin puis tronquer » (le déplacement ne marchait pas sur un fichier ouvert), archive ≤ 1 Mo, 10 min, 600.
- Correction du nettoyage plist (`plistlib`) : données d'usage TopNotch/Stats retirées des captures.
- `capture.sh --accept <chemin>…` : acceptation sélective. Scripts de secours indépendants du PATH (testés sous `env -i`).
- `docs/actions-humaines.md` : checklist H1–H7.

## 2026-10-08 (réception)
- `verify.sh` : les entrées TCC « RÉSIDU » (BetterDisplay, BetterTouchTool, bash) sortent du calcul de conformité et sont
  rapportées à part ; une entrée résiduelle du store Nix **accordée** est affichée en ALERTE SÉCURITÉ.
- Constat : l'entrée `bash` refusée à 15:55 a été réactivée à 16:09:51 dans Réglages (origine non établie) ; suppression demandée.
- Décisions utilisateur : bordure et barre OmniWM gardées désactivées (dépôt et `apply-registry.py` alignés) ;
  BetterTouchTool désinstallé (`brew uninstall --cask`, sans `--zap`). Retour : `brew install --cask bettertouchtool`.
- Historique Git : données d'usage TopNotch/Stats examinées (faible sensibilité) ; historique conservé.
- Note : l'export Raycast doit être sauvegardé hors du Mac.

- Cmd+E → Finder (demande utilisateur) : `~/.hammerspoon/poweruser-apps.lua`, chargé par `init.lua`. Remplace Cmd+E natif. Retour : retirer le `require` de `init.lua` et recharger Hammerspoon.

- Navigation simplifiée (Hyper jugé trop complexe) : Ctrl+1–4 bureaux, Ctrl+Shift+1–4 transfert, Option+Tab fenêtre précédente
  (testés S) ; OmniWM 4 doigts horizontal = bureaux, macOS 4 doigts horizontal désactivé (valeur d'origine 2, sauvegardée).
  Retour : `backups/omniwm-163914-avant-ctrl/`.
- Mise en page : 3 fenêtres visibles par bureau (`visibleContainerCount = 3`, colonnes au tiers ; 1–2 fenêtres remplissent l'écran),
  `edgeGaps = false`, espace entre fenêtres 8 px, aucune réservation de barre ; Ctrl+←/→ focus, Ctrl+Shift+←/→ déplacer (testés S) ;
  symbolichotkeys 79–82 désactivés ; barre des menus masquée automatiquement (System Events). Bande de 40 px = encoche (macOS).
  Retour : `backups/navig-175131/`.
- `com.apple.FolderActionsDispatcher` réactivé (153 services désactivés) juste après l'appel System Events pour la barre des menus ; origine probable des deux bascules : System Events (non prouvé). Aucune action corrective.
- Marges OmniWM 8 px (gauche, droite, bas) ; haut 0. Une marge haute négative (-32) a été testée : **ignorée** par OmniWM 0.7.6 — la limite haute reste celle de macOS (40 px, encoche), barre des menus masquée ou non.
- `FolderActionsDispatcher` rebasculé après un `osascript quit` : bascule liée aux appels osascript ; exclu du décompte de `snapshot.sh` (état affiché à part).
- Fenêtre seule : `singleWindowFit = "2161x1351"` (au lieu de "fill", qui ignorait les marges — Safari collé aux bords) ; `outer.top = 48` (mesuré depuis le bord physique : 40 px d'encoche + 8). Résultat mesuré : 8 px sur les 4 côtés (Safari seul, Ghostty) ; Terminal 2 px en bas (hauteur arrondie aux lignes). Taille fixe à adapter si un écran externe est utilisé. Retour : `backups/omniwm-*-avant-fit/`.
- Thème : Stylix `release-26.05` intégré au flake (sans cible : aucune app thémée) ; fond d'écran copié dans `wallpapers/actuel.png` ; génération de palette **vérifiée sur aarch64-darwin**. Palette brute : accents tous roses (illisible pour erreurs/succès/diff) → palette ajustée proposée (`docs/theme-palette-*.png`).
- Thème « Lune rose » (palette B) appliqué : Stylix → Ghostty, Starship, bat, fzf, Lazygit, Yazi, btop ; dépôt → Neru,
  bordure OmniWM (base0E), alertes Hammerspoon ; accent macOS Rose (6). Ghostty et btop passent sous Home Manager
  (btop Homebrew désinstallé). Test visuel Ghostty OK (6 couleurs distinctes). Recherche rétro-ingénierie encoche : aucune
  solution sans injection ; documentée.
- Thème « Océan » (nouveau fond d'écran `Unknown-2.png`) : palette ajustée (génération brute = 8 accents gris-bleu), accent du poste = base0D partout, accent macOS calculé (Bleu). `scripts/theme-sync.sh` : synchronisation en une commande. Image précédente gardée : `wallpapers/lune-rose.png`.
- Thème **automatique** : `scripts/palette-from-image.py` (palette lisible depuis l'image), `home-manager/palette.nix` (généré),
  agent `theme-auto` (WatchPaths sur l'index des fonds d'écran) → `scripts/theme-auto.sh` → `theme-sync.sh` (OmniWM rechargé à chaud,
  plus d'AppleScript) ; accent macOS choisi par teinte. Testé : changement réel de l'utilisateur (18:38) et deux bascules (25 s chacune).
  Note : le premier commit automatique `b1672e0` contient aussi les scripts alors indexés (palette-from-image, theme-auto, startup.nix).
- OmniWM pleine hauteur : fiche Xcode ouverte dans l'App Store et formulaire d'issue OmniWM pré-rempli ouvert dans Safari (publication et installation par l'utilisateur).
- Debloat : `com.apple.amsengagementd` réactivé (ciblé) — l'achat d'Xcode échouait (erreur 4099 sur ce service désactivé).
- Xcode 27.0 installé depuis developer.apple.com (`Xcode_27.xip`, signature Apple vérifiée) ; licence à accepter par l'utilisateur.
- Licence Xcode acceptée par l'utilisateur ; `xcode-select` pointe désormais vers Xcode (git 2.54 Apple). Résidu de préférences de la copie de test Ghostty supprimé.
- OmniWM : option `fullHeightWhenMenuBarHidden` implémentée sur une branche locale (make verify OK, 38 tests ciblés OK). La suite complète lancée sur le poste a bloqué puis gelé le Mac (redémarrage 20:45) : règle ajoutée, ne lancer que des tests ciblés. Reprise après redémarrage vérifiée (post-session-check).
- OmniWM Dev essayé sur le poste : avec l'option, toutes les apps testées se recalent sous l'encoche et perdent leur marge basse (effet négatif). Retour à OmniWM officiel (`make use-release`), marges 48/8 vérifiées. GitHub connecté (compte de l'utilisateur) ; rien publié.
- OmniWM Dev (essai) rangé dans les sauvegardes privées (`backups/omniwm-dev-essai-*`) ; ses autorisations TCC sont classées résidus.

## 2026-10-08 — AeroSpace remplace OmniWM
- OmniWM (Niri puis Dwindle) jugé trop instable ; AeroSpace 0.21.3 (tap nikitabobko) : config tools/aerospace/aerospace.toml, démarrage via startup.nix.
- Raccourcis conservés (Ctrl+1..9, Ctrl+Maj+1..9, Ctrl+flèches). OmniWM et ses réglages gardés pour un retour.
- 2026-10-09 : AeroSpace retiré aussi ; placement natif macOS activé (EnableTilingByEdgeDrag, EnableTopTilingByEdgeDrag, EnableTilingOptionAccelerator, EnableTiledWindowMargins = 1).
- 2026-10-09 : retour à OmniWM (Dwindle) à la demande ; placement natif remis par défaut.
- 2026-10-09 : AeroSpace désinstallé (config archivée) ; export Raycast déplacé dans le dossier privé ; STATUS mis à jour.
- 2026-10-09: main docs in English (README, AGENTS, STATUS, architecture, shortcuts, secrets); Dwindle Ctrl+Option shortcuts fixed for AZERTY (W/A/Q/Z were on QWERTY positions).
