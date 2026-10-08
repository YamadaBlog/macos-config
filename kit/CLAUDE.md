# Déploiement macOS power user

- Mission : PROMPT-OPUS-5.5.txt. Détails : deployment/RUNBOOK-OPUS.txt ; cible : deployment/profile.json.
- Exécuter sur le Mac vérifié. Les templates n’ont pas été déployés ni évalués par Nix ici.
- Nix/HM = CLI/shell ; Brew autonome = GUI ; un WM, un clipboard et un propriétaire par config/service.
- Prévol : bash bin/ops-preflight.sh ; diagnostic : bash bin/diagnostic.sh.
- Aperçu d’un module : bash bin/install-stage.sh MODULE ; appliquer un seul module avec --apply après sauvegarde.
- Avant mutation : conserver l’état et le rollback. Fusionner les configs ; pas de force pour contourner un conflit.
- État PRIVÉ : ~/.local/state/macos-power-user-deploy/state.json, journal.txt, resume.txt. Pas de logs sensibles dans Git.
- Après reprise : relire cet état, Git et le dernier test pertinent ; continuer sans réinstaller un composant valide.
- Tests : deployment/checklist.tsv. Installed/configured ne signifie pas tested. Preuves natives requises.
- Pas d’achat/publication, de nouveau debloat, de reboot forcé ni de changement SIP/SSV/boot-args/sudoers.
- Ne pas clôturer avec une promesse de prochaine étape si un travail accessible reste ouvert.
- Clôture : socle testé et compléments décidés, ou blocage réel de tout travail restant ; bilan expurgé dans BILAN-DEPLOIEMENT.txt.
- Si compaction disponible, préserver autorisation, décisions, changements, preuves, backups, rollback et prochaine action.
