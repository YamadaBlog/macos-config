BRANCHE SYSTÈME CIBLÉE — MODÈLE NON ÉVALUÉ ICI
Ops doit construire, inspecter et adapter la configuration avant toute activation.
Ce dossier ne gère ni Home Manager, ni Homebrew, ni le daemon Nix/Lix. Cela ne signifie pas que nix-darwin ne touche aucun autre fichier système : inspecter son activation et les fichiers /etc avant switch.

PRÉREQUIS
Inventaire debloat et fonctions dépendantes vérifiées ; sauvegarde suffisante ; compte/chemin réels dans identity.nix ; tous les fichiers Nix suivis par Git. Si un nix-darwin préexiste, intégrer une branche dans SA configuration plutôt que créer un second propriétaire.
Conserver la valeur ET le type / l’absence des clés Finder/Dock. Une déclaration retirée ne rétablit pas automatiquement les anciennes préférences.

CONSTRUIRE (depuis nix-darwin/)
nix flake lock
nix build '.#darwinConfigurations.mac.system' --out-link result-darwin
Lire l’activation générée, les modifications et conflits ; pas de --force ni de réécriture aveugle de /etc.
La référence master en ligne peut différer de la branche stable : vérifier les options effectivement évaluées.

ACTIVER (uniquement après contrôles, via authentification normale)
Si darwin-rebuild de la branche existe : sudo darwin-rebuild switch --flake .#mac
Sinon utiliser le darwin-rebuild issu du résultat construit : sudo ./result-darwin/sw/bin/darwin-rebuild switch --flake .#mac
Vérifier le chemin et --help du binaire réellement construit avant cet appel ; si layout différent, adapter d’après la documentation de la release.
Aucune commande n’a été exécutée sur le Mac lors de la préparation.

RETOUR
Choisir une génération système précédente si elle existe ; vérifier la commande de rollback de la version installée. Première activation : pas de génération ancienne présumée ; conserver sauvegardes et procédure officielle de désinstallation, sans retirer Nix/Lix géré séparément.
Restaurer séparément les anciennes préférences Finder/Dock et fichiers affectés selon le relevé.
Ne pas intégrer les 136 services désactivés, ni SIP/SSV/boot-args/sudoers, dans cette branche.

Sources : https://github.com/nix-darwin/nix-darwin ; https://nix-darwin.github.io/nix-darwin/manual/ ; https://github.com/nix-darwin/nix-darwin/blob/master/modules/examples/simple.nix
