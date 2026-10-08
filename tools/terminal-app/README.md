# Terminal (Apple)

**Statut :** actif (constat)
Version, provenance : voir `inventory/elements.tsv` et `docs/generated/versions.tsv`.

| | |
|---|---|
| Rôle / raison | Terminal où tourne la session Claude Code ; doublon fonctionnel de Ghostty. |
| Gestion (install, config, MAJ) | Apple. |
| Emplacements | Préférences `com.apple.Terminal` (profils). |
| Dépendances | — |
| Permissions | Enregistrement d'écran possible. |
| Démarrage | — |

## Paramètres
| Capturés (dans ce dépôt) | Reproductibles (script/commande) | Manuels (procédure) | Inconnus |
|---|---|---|---|
| — | — | Profil par défaut « Clear Dark » ; export privé `~/.local/share/macos-config-private/terminal/com.apple.Terminal-<date>.plist`. | — |

Fichiers capturés : aucun

## Mise à jour
macOS.

## Restauration
`defaults import com.apple.Terminal <export privé>` (Terminal quitté).
