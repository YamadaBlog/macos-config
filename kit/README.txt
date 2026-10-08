POUR CLAUDE OPUS 5.5 : lire DEPLOIEMENT-OPS.txt et utiliser PROMPT-OPUS-5.5.txt. Le profil cible y précise les variantes retenues.

MACOS POWER USER — PLAN ET KIT RÉVISÉS LE 8 OCTOBRE 2026
Profil signalé : macOS 26.6, Apple Silicon M5 Max, écran intégré, AZERTY Français standard, trackpad.
SIP désactivé selon utilisateur ; SSV scellé. Rien n'a été installé ou modifié sur le Mac par ce kit.

ORDRE
0. Lire le PDF, lancer le diagnostic et reconstituer les changements du debloat.
1. Sauvegarde Time Machine + restauration test, copie des fichiers de configuration concernés.
2. Git + Nix/Lix + Home Manager pour CLI ; Homebrew indépendant pour apps graphiques.
3. Ghostty, puis shell Nix ; Atuin et TUI uniquement si utiles.
4. Essai OmniWM seul ; Paneru comme alternative, jamais un deuxième WM actif.
5. Raycast, puis Neru et gestes BTT si leurs fonctions manquent réellement.
6. Thème, contextes/projets, modules Finder et système.
7. Stats, sauvegardes/synchronisation et accès distant ciblés.
8. Déclaratif système nix-darwin ; branche yabai/SA uniquement après validation préalable.

COMMANDES DEPUIS LE KIT
bash bin/diagnostic.sh
bash bin/backup-configs.sh
bash bin/install-stage.sh --list
bash bin/install-stage.sh terminal
Sans --apply : aperçu pour les scripts qui modifient des fichiers/installent des modules.
Après sauvegarde et lecture : bash bin/install-stage.sh --apply terminal
Un module à la fois, ouverture manuelle, permissions et tests avant démarrage automatique.
Aucun lancement de service automatique dans install-stage.sh. Homebrew peut télécharger des dépendances.
--no-upgrade n'est pas un verrou de version ; versions vérifiées dans sources.json/PDF, pas garanties par le Brewfile.

NIX
Lire nix/README.txt. identity.nix doit être complété ; pas de flake.lock fabriqué.
CLI/backup/sync ne sont plus installés par les Brewfiles : Nix en est le propriétaire.
Modèle volontairement petit ; enableShell=false au départ. Nix non évalué ici.
Home Manager seul d'abord ; nix-darwin et nix-homebrew ne sont pas activés par le kit.

FENÊTRES / AZERTY
OmniWM 0.7.6 : app et CLI IPC 19 doivent être cohérents.
Défilement du contenu = 2 doigts ; colonnes = 3 ou 4 doigts, pas 2.
Définir les raccourcis dans l'app, puis exporter sa configuration valide.
keybindings.tsv est une proposition, pas une configuration importable.
W/E/D/T sont proposés à la place de chiffres AZERTY ; vérifier chaque touche physiquement.
Caps Lock/Hyper non remappé automatiquement.
Paneru : suivre son installation officielle, commencer en premier plan avant le service.

MODULES FACULTATIFS
launcher=Raycast ; gestures=BTT ; monitoring=Stats ; contexts=Bunch ; projects=Hammerspoon.
Choisir un moteur de contexte et un seul historique de copie actif (OmniWM, Raycast ou Maccy).
Raycast payant n'est pas nécessaire au départ. BTT est propriétaire avec essai de 45 jours.
Quicksilver/SwiftBar/SketchyBar et les anciens modules restent des alternatives, pas un socle cumulatif.

CONFIGS ET RETOUR ARRIÈRE
Ne pas copier tous les presets. Sauvegarder et fusionner les options choisies.
apply-theme.sh remplace un fichier Ghostty après sauvegarde ; fusion manuelle conseillée si personnalisé.
Hammerspoon : charger les modules retenus depuis init.lua ; projets désactivés tant que non adaptés.
Lire BRANCHE-YABAI.txt avant ce backend ; effets runtime avec sauvegarde et restauration, pas SA automatique.
backup-configs.sh ne couvre qu'une sélection de fichiers, pas Nix, données utilisateur ou toutes les apps.
Conserver le dépôt Git, la sauvegarde complète et les exports propres aux apps.
Aucun changement root/SIP/SSV/boot-args/sudoers automatisé.
Voir verification.txt pour les contrôles réellement exécutés et leurs limites.
