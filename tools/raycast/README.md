# Raycast

**Statut :** actif — testé (S)
Version, provenance : voir `inventory/elements.tsv` et `docs/generated/versions.tsv`.

| | |
|---|---|
| Rôle / raison | Lanceur (Cmd+Espace), quicklinks, snippet, historique du presse-papiers unique ; version gratuite, aucun compte. |
| Gestion (install, config, MAJ) | Installation : cask. Config : interface (base chiffrée). MAJ : intégrée. |
| Emplacements | Privé : `~/Library/Application Support/com.raycast.macos/` (bases chiffrées dont presse-papiers), `~/.config/raycast/aster-endpoint.json` (jeton). Prefs : `com.raycast.macos` (onboarding, sans compte). |
| Dépendances | Spotlight retiré de Cmd+Espace (symbolichotkeys 64 désactivé). |
| Permissions | Accessibilité (accordée, TCC). |
| Démarrage | Élément d'ouverture propre à Raycast (« Open at Login » activé) — seul mécanisme. |

## Paramètres
| Capturés (dans ce dépôt) | Reproductibles (script/commande) | Manuels (procédure) | Inconnus |
|---|---|---|---|
| — | Raccourci Spotlight : `/usr/libexec/PlistBuddy -c 'Set :AppleSymbolicHotKeys:64:enabled false' ~/Library/Preferences/com.apple.symbolichotkeys.plist` puis `activateSettings -u`. | Réglages (procédure de recréation) : Hotkey ⌘ Espace ; quicklinks « Dépôt macos-config » (`/Users/mao/dev/macos-config`, Finder) et « Recherche web » (`https://duckduckgo.com/?q={Query}`, Safari) ; snippet « Formule courriel » mot-clé `;bjr` ; Clipboard History : 1 semaine, exclusions Trousseaux d'accès + Mots de passe ; thème Raycast Dark/Light (suit le système). Export chiffré : Settings > Advanced > Export → `~/.local/share/macos-config-private/raycast/` (mot de passe choisi par l'utilisateur). | Extensions du Store : aucune détectée (base illisible) ; export non encore réalisé. |

Fichiers capturés : aucun

## Mise à jour
Auto.

## Restauration
Importer le .rayconfig (Settings > Advanced > Import) ; ou recréer selon la colonne « Manuels ». Spotlight : réactiver la clé 64 (`backups/symbolichotkeys.pre-raycast.plist`).
