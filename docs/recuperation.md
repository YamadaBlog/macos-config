# Récupération : un outil ou un raccourci bloque le poste

Ordre d'escalade : du plus léger au plus fort. Aucune étape ne modifie la configuration.

## 1. Le clavier fonctionne encore
| Situation | Action |
|---|---|
| Un mode Neru reste affiché | Échap |
| Raccourcis Hyper inactifs / fenêtres mal placées | Terminal ou Ghostty : `~/dev/macos-config/scripts/emergency-stop.sh` |
| Une app ne répond plus | Cmd+Option+Échap (Forcer à quitter) |
| Seul Neru pose problème | `launchctl bootout gui/$(id -u)/org.nix-community.home.neru` (arrêt durable jusqu'à la prochaine session) |
| Seul OmniWM | `launchctl bootout gui/$(id -u)/org.nix-community.home.omniwm; osascript -e 'quit app "OmniWM"'` — les fenêtres restent à leur place courante |
| Seul Hammerspoon | `launchctl bootout gui/$(id -u)/org.nix-community.home.hammerspoon; osascript -e 'quit app "Hammerspoon"'` |

Ouvrir un terminal sans raccourci : Cmd+Espace (Raycast) → « Terminal » ; si Raycast ne répond pas : Finder >
Applications > Utilitaires > Terminal (Cmd+Maj+U dans le Finder).

## 2. Le clavier ne répond plus
- Souris/trackpad : menu Pomme > Forcer à quitter… (OmniWM, Hammerspoon, Neru).
- Depuis un autre appareil : la Connexion à distance (sshd) est active sur ce poste → `ssh mao@<IP Tailscale ou locale>`
  puis `~/dev/macos-config/scripts/emergency-stop.sh` (non testé à distance).
- En dernier recours : maintenir le bouton d'alimentation (perte du travail non enregistré).

## 3. Revenir à la normale
`~/dev/macos-config/scripts/emergency-start.sh` (recharge les trois agents, vérifie IPC et Neru), puis `scripts/verify.sh`.
Les agents sont aussi rechargés à la prochaine ouverture de session.

Les scripts fixent leur propre `PATH` et appellent `omniwmctl`/`neru` par chemin absolu : ils fonctionnent depuis
**Terminal.app**, une session SSH ou un shell sans profil (Ghostty et OmniWM non requis).

## Tests réalisés (simulés)
- Sous `env -i` (environnement vide, depuis la session Terminal.app) : arrêt des 3 outils, puis relance (1 instance chacun, IPC « pong »).
- `emergency-stop.sh` : 3 agents déchargés, 3 processus arrêtés, **aucune relance après 35 s**.
- `emergency-start.sh` : 1 instance de chaque, IPC OmniWM « pong », Neru « running », 4 bureaux présents.

## Comportements de relance (testés)
| Cas | Résultat |
|---|---|
| Neru arrêté anormalement (`kill -9`) | relancé (KeepAlive) |
| Neru arrêté proprement (SIGTERM, Quitter) | code 0 → **non relancé** |
| Échec persistant (agent témoin `/usr/bin/false`) | relance toutes les `ThrottleInterval` secondes, sans fin (launchd n'a pas de plafond) ; Neru : 30 s → au plus 2 relances/min ; arrêt : `launchctl bootout …neru` |
| OmniWM, Hammerspoon, Stats | lancés une fois à l'ouverture de session (pas de KeepAlive) |

## Incident 2026-10-08 15:31 (à ne pas reproduire)
Un lanceur bash intermédiaire autour de Neru (pour plafonner les relances) a fait **réinitialiser par Neru sa propre
autorisation Accessibilité**. Retour immédiat au lancement direct ; autorisation réaccordée par l'utilisateur à 15:33.
Effet secondaire : une autorisation Accessibilité a été créée à 15:32 pour
`/nix/store/hr5jdf535nm54yq3jzkyx8k9a0m3hwql-bash-5.3p9/bin/bash`. Elle a été **désactivée par l'utilisateur à 15:55:39**
(`auth_value = 0`) ; l'entrée reste listée tant qu'elle n'est pas supprimée (« – »). Neru testé ensuite : hints/grid/scroll OK.
Règle : lancer Neru (et toute app soumise à TCC) **directement** dans `ProgramArguments`, jamais via un script parent.
