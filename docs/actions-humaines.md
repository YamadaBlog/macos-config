# Interventions humaines restantes (checklist unique)

Ne jamais coller de mot de passe ni de secret dans la conversation. Répondre à l'assistant par numéro.

| # | Action | Comment | Réponse attendue |
|---|---|---|---|
| H1 | Supprimer l'entrée Accessibilité « bash » (déjà désactivée à 15:55) | Réglages Système > Confidentialité et sécurité > Accessibilité → sélectionner « bash » (`/nix/store/hr5jdf535nm54yq3jzkyx8k9a0m3hwql-bash-5.3p9/bin/bash`) → « – » → s'authentifier. Ne toucher à aucune autre ligne. | « H1 fait » |
| H2 | Choisir l'état de la bordure (2 px bleu nuit) et de la barre de bureaux d'OmniWM | Elles sont actuellement **désactivées** ; la désactivation de 15:34 a une origine inconnue (non reproduite par la relance des outils). | « H2 : garder désactivées » ou « H2 : réactiver » (ou l'une des deux) |
| H3 | Faire la séance de tests | `docs/tests-manuels.md`, points 1 à 12 (≈ 10 min) | « n° OK » ou « n° KO + ce qui s'est passé » pour chaque point |
| H4 | Exporter Raycast | Raycast > Settings > Advanced > Export → choisir un mot de passe que tu conserves toi-même → enregistrer dans `~/.local/share/macos-config-private/raycast/` | « H4 fait » (l'assistant vérifie seulement la présence du fichier) |
| H5 | Indiquer une destination Time Machine | Brancher un disque externe ou fournir un partage réseau (SMB) disponible ; dire s'il peut être effacé ou s'il contient déjà des données | nom du disque/partage + « formatage autorisé : oui/non » |
| H6 | Décider du nettoyage | N1 désinstaller BetterTouchTool (ses extensions Safari/Finder ne sont pas activées) ; N3 supprimer l'entrée Accessibilité de BetterDisplay (app absente) — voir `docs/nettoyage.md` | « N1 oui/non », « N3 fait/non » |
| H7 | Autoriser déconnexion puis redémarrage (après H3, travail enregistré) | Après reconnexion : `~/dev/macos-config/scripts/post-session-check.sh`, puis dire « reprends » à l'assistant | « H7 autorisé » |

L'ancien dépôt `~/Projects/macos-config` est conservé ; sa suppression n'est pas demandée.
