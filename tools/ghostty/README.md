# Ghostty

**Statut :** actif — testé (S + I)
Version, provenance : voir `inventory/elements.tsv` et `docs/generated/versions.tsv`.

| | |
|---|---|
| Rôle / raison | Terminal (thème Bleu Nuit glass : opacité 0.94, flou) ; lisibilité vérifiée par capture. |
| Gestion (install, config, MAJ) | Installation : cask. Config : fichier. MAJ : intégrée. |
| Emplacements | `~/.config/ghostty/config.ghostty` ↔ `tools/ghostty/config/config.ghostty`. Variante opaque : `kit/configs/ghostty-opaque.config.ghostty`. |
| Dépendances | Shell Home Manager : ouvrir une NOUVELLE fenêtre après une modification du shell (une fenêtre de 13:13 n'avait pas les CLI Nix). |
| Permissions | Enregistrement d'écran (captures). |
| Démarrage | Non lancé à la session (au choix). |

## Paramètres
| Capturés (dans ce dépôt) | Reproductibles (script/commande) | Manuels (procédure) | Inconnus |
|---|---|---|---|
| Config complète. | — | — | — |

Fichiers capturés : `config/config.ghostty`

## Mise à jour
Auto ; `ghostty +validate-config`.

## Restauration
`scripts/apply.sh ghostty --write`.

## Depuis le 2026-10-08
Configuration **générée par Home Manager** (`programs.ghostty`, `package = null` : l'app reste installée par Homebrew),
couleurs par Stylix (`theme = stylix`). Ancienne config : `~/.config/ghostty/config.ghostty.pre-hm` (ne plus utiliser :
Ghostty lit aussi `config.ghostty` s'il existe). Recommandé : lancer Claude Code dans Ghostty (marges exactes, panneaux Cmd+D).
