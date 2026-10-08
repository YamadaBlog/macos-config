SOCLE NIX — 8 OCTOBRE 2026
Ce modèle est préparé, pas évalué par Nix ni déployé sur le Mac. Validation native requise.
Architecture : Home Manager autonome ; Nix = CLI/shell ; Homebrew = apps graphiques.
Les réglages OmniWM restent modifiables dans son interface pendant les essais.

1. Lire https://lix.systems/install/ et vérifier une éventuelle installation Nix existante.
   Nouveau Mac sans Nix : utiliser l'installateur Lix officiel après lecture de sa procédure.
   Ne pas superposer Lix/Nix/Determinate ni remplacer un daemon existant sans diagnostic.
   Garder le reçu et la procédure de désinstallation de l'installateur.
2. Nouveau terminal : nix --version. Si nécessaire, activer nix-command et flakes selon la documentation de l'installation retenue.
3. Copier le kit dans ~/Projects/macos-config (sans écraser un dépôt existant).
   Éditer nix/identity.nix : id -un et chemin personnel réel. Garder enableShell=false.
4. Depuis la racine du dépôt :
   git init
   git add .gitignore nix manifests configs bin *.txt *.tsv sources.json
   Relire les fichiers suivis : pas de secrets ni d'historiques. Un dépôt public exige une revue supplémentaire.
   cd nix
   nix flake lock
   nix build '.#homeConfigurations.mac.activationPackage' --out-link result-home
   Cette construction crée le lock/store/résultat, mais n'active pas le profil utilisateur.
5. Après lecture des conflits éventuels et sauvegarde des fichiers concernés :
   ./result-home/activate
   Ouvrir un nouveau terminal ; command -v rg fzf zoxide bat jq starship home-manager
   Vérifier le PATH, une seule origine voulue par paquet. Ne pas supprimer les paquets Brew avant ce contrôle.
6. git add flake.lock ; revenir à la racine pour un commit local relu.
7. Plus tard : enableShell=true ; sauvegarder .zshrc/.zshenv/.zprofile et éventuel XDG zsh.
   Depuis nix/ : home-manager switch --flake .#mac
   Conserver les intégrations PATH Lix/Nix et Homebrew nécessaires ; reprendre les fichiers existants explicitement.
   Ne pas forcer l'écrasement de dotfiles pour contourner un conflit.
8. Activer Atuin/TUI/dev/restic/sync séparément, en rebuildant à chaque fois.
   Atuin : local, pas de compte/sync automatique ; son Ctrl-R remplace ici l'intégration fzf.
   Direnv : relire .envrc avant direnv allow ; elle exécute du code.
   Syncthing : installation du binaire seulement ; dossiers/services et réseau restent à définir.
   Restic : définir une destination et protéger la clé avant création d'une tâche.

RETOUR ARRIÈRE
home-manager generations : choisir explicitement la génération précédente, puis exécuter son chemin .../activate.
Les générations restaurent les déclarations qu'elles gèrent, pas les données, apps Brew ou permissions macOS.
Pour une première activation sans génération antérieure : préserver les sauvegardes de dotfiles et suivre la désinstallation officielle Home Manager.
Ne pas faire de garbage collection avant validation et période de retour arrière.
Nix n'est ni une sauvegarde du Mac ni une promesse de verrouillage des casks Homebrew.

NIX-DARWIN : PHASE TARDIVE
Commencer par un seul réglage système identifié, construire avant switch et conserver sa valeur précédente.
L'ancien debloat doit être compris avant de gérer launchd/defaults via nix-darwin.
Vérifier qui possède le daemon Nix ; nix-darwin utilise Nix par défaut : conserver explicitement Lix si retenu.
Home Manager peut rester autonome ; le migrer en module Darwin n'est pas obligatoire.
Ne pas activer nix-homebrew dans ce premier parcours : Homebrew géré par Nix relève du Tier 3 Homebrew.
Sources : https://github.com/nix-community/home-manager ; https://github.com/nix-darwin/nix-darwin ; https://github.com/zhaofengli/nix-homebrew ; https://docs.brew.sh/Support-Tiers
