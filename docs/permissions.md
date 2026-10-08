# Permissions macOS (TCC)

Source de vérité : `inventory/permissions.tsv` (attendu) comparé à la base TCC réelle par `scripts/verify.sh`
(lisible parce que le terminal dispose de l'accès complet au disque ; sinon la section est marquée « non vérifiable »).
Seul l'utilisateur accorde ou retire une permission : Réglages Système > Confidentialité et sécurité > <service>.

| App | Permission | Justification | État (TCC, 2026-10-08) | Test après octroi |
|---|---|---|---|---|
| OmniWM | Accessibilité | gérer les fenêtres | accordée | `omniwmctl ping` ; Hyper+E |
| OmniWM | Enregistrement d'écran | Overview, aperçus | accordée (14:06) | Hyper+O |
| Neru | Accessibilité | éléments cliquables | accordée | Hyper+N |
| Hammerspoon | Accessibilité | hotkeys, contextes, tests | accordée | Hyper+P |
| Raycast | Accessibilité | collage, snippets | accordée | `;bjr` se développe |
| Stats | Accessibilité | accordée à l'installation, non requise | accordée | — |
| Lunar | Accessibilité | préexistant | accordée | — |
| BetterTouchTool | Accessibilité, AppleEvents, Bluetooth | app écartée | accordées → **à retirer** si désinstallée | — |
| BetterDisplay | Accessibilité | **résidu** : app absente | accordée → **à retirer** (Accessibilité, sélectionner, « – ») | — |
| Discord | Accessibilité, surveillance du clavier | non nécessaires | refusées | — |
| Terminal (session de l'assistant) | Accès complet au disque, Enregistrement d'écran | lecture TCC, captures de contrôle | accordées (apps Apple non listées dans l'inventaire) | — |

Après une mise à jour qui change la signature d'une app, macOS peut révoquer l'autorisation :
`scripts/verify.sh` affiche alors « ATTENDUE ABSENTE ».
