# Décisions (modules conditionnels et alternatives)

Règle : rien n'est installé « au cas où ». Chaque module répond à un besoin observé, sinon il est différé ou écarté.
Un seul outil par fonction (fenêtres, presse-papiers, gestes, monitoring, paquets).

| Module | Décision | Justification (besoin concret) | Condition de révision |
|---|---|---|---|
| BetterTouchTool | **désinstallé** le 2026-10-08 (décision utilisateur) | gestes déjà répartis : 2 doigts contenu, 3 doigts horizontal OmniWM, 3 vertical / 4 doigts macOS ; les gestes restants (tap 3 doigts = Recherche macOS, tap 4 doigts) ne font rien de plus que Hyper+P ou Raycast ; 242 Mo résidents ; essai menant à un achat | besoin d'un geste précis non couvert |
| LocalSend | différé | aucun échange régulier Windows/Android observé (machines Tailscale hors ligne depuis 95/186 jours) ; AirDrop couvre Apple | échange de fichiers avec un appareil non Apple |
| Quick Look (syntax-highlight) | écarté | aperçu texte natif suffisant ; `bat` et Ghostty couvrent la lecture de code | besoin d'aperçus colorés dans le Finder |
| Dictée locale (VoiceInk, Superwhisper…) | différé | utile pour dicter des prompts, mais payant ou à compiler, et la dictée macOS est probablement affectée par le debloat (`corespeechd` désactivé) : tester d'abord la dictée native | décision d'achat ou test de la dictée native |
| direnv / devshell | différé | aucun projet de développement dans `~/dev` hormis ce dépôt | premier projet avec dépendances propres (`profile.nix: enableDev = true`) |
| Syncthing | différé | aucun dossier ni appareil à synchroniser défini ; ce n'est pas une sauvegarde | besoin de synchronisation entre appareils |
| restic | différé | dépend d'une destination de sauvegarde (aucune) | destination définie (disque, NAS, cloud) |
| BetterDisplay | écarté | écran interne seul ; Lunar présent ; ancienne installation retirée (résidu TCC à nettoyer) | écran externe nécessitant HiDPI/DDC |
| nix-darwin | différé | sauvegarde Time Machine absente ; Finder réglé en préférences utilisateur réversibles | Time Machine opérationnel |
| Paneru / AeroSpace / yabai | écartés | OmniWM fonctionne (IPC, bureaux, raccourcis, gestes) ; un seul WM | échec persistant d'OmniWM |
| JankyBorders / SketchyBar | écartés | bordures et barre intégrées à OmniWM activées | limite bloquante des équivalents intégrés |
| Maccy | écarté | Raycast est l'historique unique (rétention 1 semaine, exclusions trousseau/mots de passe) | Raycast inadapté |
| Karabiner / remap Caps Lock | écarté | Hyper = Ctrl+Option+Cmd sans remap, conformément au choix initial | demande explicite |
| Stats | conservé, limité | CPU, RAM, Réseau utiles pendant le travail IA ; batterie/GPU/capteurs/disque retirés (doublons ou peu utiles) | — |
| Lunar, TopNotch | conservés, non lancés | préexistants ; aucun besoin observé de les lancer | usage de luminosité fine / masquage d'encoche |
