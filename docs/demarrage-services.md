# Services et éléments de démarrage

Règle : **un seul mécanisme par outil**. `open -a` ne lance jamais une seconde instance.

| Outil | Mécanisme | Déclaré dans | Vérification |
|---|---|---|---|
| OmniWM | LaunchAgent `org.nix-community.home.omniwm` (`open -g -a OmniWM`, au chargement) | `home-manager/startup.nix` | `launchctl list \| grep home.omniwm` |
| Hammerspoon | LaunchAgent `org.nix-community.home.hammerspoon` | idem | idem |
| Stats | LaunchAgent `org.nix-community.home.stats` | idem | idem |
| Neru | LaunchAgent `org.nix-community.home.neru` (`neru launch` lancé directement ; relancé si arrêt anormal, au plus toutes les 30 s ; journal `~/Library/Logs/macos-config/neru.log`) | idem | `neru status` |
| Thème automatique | LaunchAgent `org.nix-community.home.theme-auto` (WatchPaths : `~/Library/Application Support/com.apple.wallpaper/Store/Index.plist`, `ThrottleInterval` 20 s) → `scripts/theme-auto.sh` | `home-manager/startup.nix` | `~/Library/Logs/macos-config/theme-auto.log` |
| Rotation des journaux | LaunchAgent `org.nix-community.home.logrotate` (toutes les 10 min, voir « Journaux ») | idem | tests ci-dessous |
| Raycast | élément d'ouverture propre (Raycast > General > Open at Login) | interface Raycast | Réglages > Général > Ouverture |
| Lix | LaunchDaemons `org.nixos.nix-daemon`, `org.nixos.darwin-store`, `systems.lix.nix-installer.nix-hook` | installateur Lix | `launchctl print system/org.nixos.nix-daemon` |
| Tailscale | app + extension réseau | app | `systemextensionsctl list` |
| BetterTouchTool, Lunar, TopNotch | aucun (écarté / non lancés) | — | — |

Dans Réglages > Général > Ouverture et extensions, les quatre agents Home Manager apparaissent sous le nom **« sh »**
(ils démarrent via `/bin/sh -c "wait4path /nix/store && exec …"`) : c'est normal.
Ne pas activer en plus « Lancer à l'ouverture de session » dans OmniWM, Hammerspoon, Neru ou Stats.

Effet connu : relancer un agent alors que l'app tourne déjà (`kickstart`) fait passer l'app au premier plan et peut
ouvrir sa fenêtre (console Hammerspoon, tableau de bord Stats) ; aucun effet à l'ouverture de session.

## Services système notables
- `com.openssh.sshd` chargé à la demande (Connexion à distance, préexistant) ; `~/.ssh/authorized_keys` présent (privé).
- Debloat : 154 overrides désactivés (`docs/debloat.md`).

## Tests de persistance
| Test | Résultat |
|---|---|
| Relance d'OmniWM/Hammerspoon via les agents | S : bureaux, règles, IPC, Hyper conservés ; 1 instance |
| Arrêt anormal de Neru (`kill -9`) | S : relancé en 1 s |
| Ouverture de session, veille/réveil, redémarrage | **non testés** (`docs/tests-manuels.md`) — contrôle : `scripts/post-session-check.sh` |
| Arrêt volontaire de Neru | SIGTERM → code 0 → non relancé ; arrêt durable : `launchctl bootout gui/$(id -u)/org.nix-community.home.neru` |
| Panne persistante | relance bornée par ThrottleInterval (30 s), sans plafond : voir `docs/recuperation.md` |

## Journaux (`~/Library/Logs/macos-config/`)
| Point | Comportement | Preuve |
|---|---|---|
| Fichier ouvert | launchd ouvre `neru.log` en ajout (O_APPEND) et Neru le garde ouvert : **déplacer** le fichier ne marche pas (Neru continuait d'écrire dans l'archive) → rotation par **copie de la fin puis troncature sur place** | S : déplacement → archive passée de 4 826 à 5 442 o ; troncature → aucun octet nul |
| Conservation | une archive `*.log.1` = les **1 Mo les plus récents** au moment de la rotation ; l'archive précédente est écrasée | S |
| Limite | par journal : ≤ 1 Mo d'archive + ce qui s'écrit en 10 min | S : rafale de 3 Mo → courant 0 o, archive 1 048 576 o |
| Perte possible | lignes écrites pendant la copie (fenêtre de quelques ms) | inspection du script |
| Droits | `600` imposés à chaque passage (dossier `755`) | I |
| Contenu | messages de démarrage/arrêt de Neru, chemin de config, socket IPC ; aucun motif de secret | I (`grep`) |
| Neru très bavard | contrôle toutes les 10 min ; un emballement extrême (> plusieurs centaines de Mo en 10 min) n'est pas plafonné entre deux passages | limite connue |

## Validité après mises à jour (inspecté)
- Les plists sont des **copies** réécrites par chaque `home-manager switch`/`activate` : un changement de `startup.nix` s'applique à l'activation.
- OmniWM, Hammerspoon, Stats : appelés par leur **nom** (`open -a`) → indépendants du chemin et de la version.
- Neru : chemin fixe `/Applications/Neru.app/Contents/MacOS/neru` (conservé par `brew upgrade`) ; si le cask change de chemin, `verify.sh` ne le voit pas → tester `post-session-check.sh` après une mise à jour de Neru.
- **Survie au nettoyage Nix** : le script de rotation (seule référence au store) a pour racine `current-home` ; simulation
  `nix-store --gc --print-dead` (101 chemins supprimables) : script et génération active **protégés**.
- **Version attendue après mise à jour** : chaque plist installé est identique à celui de la génération active (`cmp`, 5/5) ;
  `launchctl print` montre le chemin du script courant.
- **Anciennes références** : aucun plist ne cite l'ancien script ; il ne subsiste que dans les anciennes générations (retour arrière),
  supprimé avec elles (`home-manager expire-generations`).
