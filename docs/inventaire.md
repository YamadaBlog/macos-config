# Inventaire : périmètre, méthode, limites

Source structurée : `inventory/elements.tsv` (une ligne par élément, 17 colonnes) :
`id, nom, categorie, role, version, provenance, gestion_install, gestion_config, gestion_maj,
config_vivante, config_depot, capture, permissions, demarrage, statut, fiche, detection`.

- **capture** : `capturé` (copie dans le dépôt) · `reproductible` (déclaratif/commande) · `manuel` (procédure dans la fiche) ·
  `privé` (hors Git, voir `docs/secrets.md`) · `aucun` (défauts) · `inconnu`.
- **statut** : actif · installé · expérimental · abandonné · préexistant · origine inconnue.
- **detection** : clés `type:valeur` produites par `scripts/discover.sh` ; `verify.sh` signale toute clé
  découverte absente de l'inventaire (sauf `inventory/ignore.tsv`) et tout élément inventorié qui a disparu.

## Ce que la découverte couvre
| Source | Clé |
|---|---|
| `/Applications`, `/Applications/*/`, `~/Applications` (+ reçu App Store) | `app:` `mas:` |
| Homebrew casks, formules, taps | `cask:` `formula:` `tap:` |
| Profil Nix utilisateur, profil Lix | `nixbin:` `nixdefault:` |
| `~/.local/bin`, `/usr/local/bin` | `localbin:` `bin:` |
| Paquets pkgutil non Apple | `pkg:` |
| LaunchAgents / LaunchDaemons (utilisateur et système) | `launchd:` |
| Extensions système activées | `sysext:` |
| `~/.config/*`, fichiers cachés de `~`, dossiers non standard de `~` | `config:` `dot:` `home:` |
| Polices, Quick Look, panneaux de préférences, Services utilisateur | `plugin:` |
| crontab utilisateur | `cron:` |
| Domaines de préférences tiers (`~/Library/Preferences`) | `pref:` |
| Dossiers `~/Library/Application Support` | `appsupport:` |
| Extensions d'apps (pluginkit : widgets, Safari, Finder, partage) | `appex:` |
| Permissions TCC tierces (bases système et utilisateur) | comparées à `inventory/permissions.tsv` |

Contre-audit du 2026-10-08 : l'élargissement aux sources `pref:`, `appsupport:`, `appex:` a révélé 66 entrées absentes
de l'inventaire (données d'apps connues, 4 agents launchd, 5 extensions d'apps, une base `default.store` d'origine inconnue,
17 dossiers Apple). Toutes sont désormais rattachées à un élément ou exclues **individuellement** dans `inventory/ignore.tsv`.

## Limites (ce que l'inventaire ne garantit pas)
- **Éléments d'ouverture (BTM)** : base root, `sfltool dumpbtm` exige l'admin. Couvert indirectement : agents launchd
  (fichiers), réglages « au démarrage » lisibles des apps (Lunar), élément Raycast observé dans son interface.
- **Permissions TCC** : lisibles **seulement** tant que le terminal a l'accès complet au disque.
- **Extensions Raycast** : base chiffrée ; aucune extension du Store détectée (dossier `extensions` sans paquet), non prouvé.
- **Extensions Safari** : pluginkit liste celle de BTT (installée avec l'app) ; leur activation dans Safari n'est pas lue.
- **Gestes BTT** : aucun configuré (app écartée) ; non lus dans sa base.
- **Profils Terminal** : liste lue (`Clear Dark` par défaut) ; export privé.
- **Journal unifié** : fonctionnel (vérifié par `logger`) ; l'interroger avec `/usr/bin/log` — sous zsh, `log` est une commande interne. Les rapports de plantage ne sont pas générés pour Neru (`~/Library/Logs/DiagnosticReports` vide).
- **Apps Apple** et services `com.apple.*` : ignorés volontairement (sauf Safari/Terminal suivis).
- **Paquets de langages** (npm, pip, cargo, gem) : aucun gestionnaire utilisateur détecté (seuls python3/ruby système).
- **Contenu** des apps (projets, messages, historiques) : hors périmètre par principe.
- Les **versions** de l'inventaire sont celles du 2026-10-08 ; les versions courantes sont dans `docs/generated/versions.tsv`.

## Doublons et origines inconnues (au 2026-10-08)
| Élément | Nature |
|---|---|
| jq | Nix (prioritaire) + `/usr/bin/jq` système |
| zsh | paquet Nix ajouté par Home Manager + `/bin/zsh` (shell de connexion) |
| btop + htop | deux moniteurs préexistants |
| Terminal + Ghostty | Claude Code utilise Terminal ; Ghostty configuré |
| `~/Projects/macos-config` | ancien dépôt, abandonné |
| `~/dock-backup.plist` | sauvegarde Dock du 7 oct., origine inconnue |
| `com.apple.FolderActionsDispatcher` | désactivé après le prévol puis **réactivé** le 2026-10-08 ~17:52 ; il bascule lors d'appels `osascript` (observé 3 fois ; mécanisme non établi) ; sans incidence, exclu du décompte |
| Discord 0.0.414 | installation manuelle, source non établie |
| `com.hegenberg.bettertouchtool-setapp` (prefs) | artefact du relanceur BTT, pas une 2ᵉ installation |
| `~/Library/Application Support/default.store` | base SwiftData `APIRequestModel` créée le 2026-10-06 20:57, ouverte par aucun processus : origine inconnue, conservée |
| Autorisation TCC `pro.betterdisplay.BetterDisplay` | résidu d'une app retirée |
