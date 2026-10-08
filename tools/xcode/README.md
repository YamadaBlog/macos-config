# Xcode

**Statut :** installé le 2026-10-08 (27.0, build 27A266a)  ; licence acceptée par l’utilisateur le 2026-10-08.

| | |
|---|---|
| Rôle | Compiler et tester OmniWM (`experiments/omniwm-full-height/`) : le projet exige Xcode 27 / Swift 6.4 |
| Origine | developer.apple.com > More Downloads > « Xcode 27 » (`Xcode_27.xip`, 2,01 Go, signé « Apple Software »), extrait par `xip --expand` dans `/Applications` |
| Pourquoi pas l'App Store | l'achat échouait : `com.apple.amsengagementd` désactivé par le debloat (réactivé), puis feuille de paiement jamais affichée |
| Vérifications | `codesign --verify --deep --strict` OK ; `spctl` : accepted, source Apple System |
| Actions administrateur (utilisateur) | `sudo xcodebuild -license accept` ; facultatif : `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer` (sinon utiliser `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`) |
| Mise à jour | nouvelle archive depuis developer.apple.com (ou App Store) |
| Retour | supprimer `/Applications/Xcode.app` ; les Command Line Tools restent l'outil par défaut tant que `xcode-select` n'est pas changé |
