# Nettoyage final proposé (rien n'est exécuté sans autorisation explicite)

| # | Opération | Commande / geste | Conséquences | Retour arrière |
|---|---|---|---|---|
| N1 ✅ fait le 2026-10-08 | Désinstaller BetterTouchTool | quitter BTT ; `brew uninstall --cask bettertouchtool` | supprime l'app et ses extensions (widgets, menu Finder, extension Safari — **non activées**, Safari ne les référence pas) ; les données `~/Library/Application Support/BetterTouchTool` et prefs restent (supprimables à part : `brew uninstall --zap`) ; aucune licence perdue (essai) | `brew install --cask bettertouchtool` |
| N2 | Retirer les autorisations de BTT | Réglages > Confidentialité > Accessibilité (et Automatisation, Bluetooth) : BetterTouchTool → « – » | plus aucun accès résiduel | réaccorder si réinstallé |
| N3 | Retirer l'Accessibilité de BetterDisplay (résidu, app absente) | Réglages > Confidentialité > Accessibilité : BetterDisplay → « – » | aucune (app absente) | réinstaller l'app et réaccorder |
| N4 | Supprimer l'entrée `bash` (`/nix/store/hr5jdf535nm54yq3jzkyx8k9a0m3hwql-bash-5.3p9/bin/bash`) | Réglages Système > Confidentialité et sécurité > Accessibilité : sélectionner la ligne « bash » (son chemin s'affiche au survol), cliquer « – », s'authentifier | **déjà désactivée** par l'utilisateur à 15:55:39 (plus d'effet) ; la suppression retire la ligne restante | aucun besoin |
| N5 | Ancien dépôt `~/Projects/macos-config` | **conservé** (aucune action) | aucune config active n'y fait référence ; non mis à jour | — |

Après N1–N4 : mettre à jour `inventory/permissions.tsv` (retirer les lignes concernées), `inventory/elements.tsv`
(BTT : statut « désinstallé » ou ligne retirée) et lancer `scripts/verify.sh`.

État au 2026-10-08 16:30 : N1 fait ; N2, N3, N4 = suppression manuelle des entrées dans Réglages (bash, BetterDisplay, BetterTouchTool ×3) demandée ; N5 conservé.
