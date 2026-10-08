# Stylix — thème du poste, automatique depuis le fond d'écran

**Statut :** actif et **automatique** depuis le 2026-10-08 18:43 : changer de fond d'écran suffit (≈ 25 s).

| | |
|---|---|
| Rôle | Palette base16 commune à tout le poste, tirée du fond d'écran `wallpapers/actuel.png` |
| Source | `home-manager/palette.nix`, **généré** par `scripts/palette-from-image.py` (fond/texte = teintes dominantes de l'image ; 8 accents sur des familles de teintes fixes attirées vers l'image, écart ≥ 20°, contraste ≥ 4,5:1) |
| Thémés par Stylix | Ghostty, Starship, bat, fzf, Lazygit, Yazi, btop (`autoEnable = false`, liste explicite) |
| Thémés par le dépôt | Neru `[theme.dark]` et accent macOS (`scripts/theme-apply.sh`), bordure OmniWM (`tools/omniwm/apply-registry.py`), alertes Hammerspoon (`~/.hammerspoon/poweruser-colors.lua`, généré par HM) |
| Hors thème | Raycast (thèmes personnalisés payants), Safari, Discord, Terminal.app |
| Palette exportée | `~/.config/stylix/palette.json` (lue par les scripts) |
| Police / transparence | JetBrains Mono 13, opacité 0,94 (Stylix convertit la taille en px : `font-size` forcé à 13) |
| Accent | base0D partout (Neru, bordure OmniWM, alertes) ; accent macOS = la plus proche de base0D parmi les 8 couleurs système (calculée : Bleu pour « Océan ») |

## Chaîne automatique
1. macOS écrit l'index des fonds d'écran → l'agent `org.nix-community.home.theme-auto` (WatchPaths) lance `scripts/theme-auto.sh`.
2. Si l'empreinte de l'image diffère de `wallpapers/source.sha256` : `scripts/theme-sync.sh` copie l'image (`wallpapers/actuel.png`),
   génère `home-manager/palette.nix`, applique Home Manager (Ghostty, Starship, bat, fzf, Lazygit, Yazi, btop), Neru, accent macOS
   (teinte la plus proche de base0D), bordure OmniWM (rechargée à chaud), recharge Ghostty et Hammerspoon.
3. Capture et commit **des seuls fichiers du thème** (« auto: thème depuis le fond d'écran … »), notification macOS.
Journal : `~/Library/Logs/macos-config/theme-auto.log`. Fonds dynamiques ou système (sans fichier image) : ignorés.
Manuel : `scripts/theme-sync.sh` (même chaîne, sans commit). Désactiver : `launchctl bootout gui/$(id -u)/org.nix-community.home.theme-auto`.
Palette à la main : remplacer `base16Scheme = import ./palette.nix;` par un attrset dans `theme.nix` **et** désactiver l'agent.

## Tests (2026-10-08)
| Test | Résultat |
|---|---|
| Générateur sur 2 images | accents distincts (8 teintes séparées ≥ 20°), contraste mini 5,1–5,4:1 |
| Changement réel de fond par l'utilisateur (18:38) | détecté et appliqué par l'agent |
| Océan → Lune rose → Océan… (simulé via System Events) | 25 s par bascule, palette, Neru, accent, OmniWM, Ghostty à chaud, commit automatique |

## Retour
Retirer `./theme.nix` des imports de `home.nix` ; anciennes configs : `~/.config/ghostty/config.ghostty.pre-hm`, `~/.config/btop/btop.conf.pre-hm`,
sauvegardes `backups/theme-*`, `backups/theme-apply-*` (Neru, accent), `backups/omniwm-*-avant-theme.toml`.
