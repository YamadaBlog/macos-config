# Lunar

**Statut :** installé (préexistant), non modifié
Version, provenance : voir `inventory/elements.tsv` et `docs/generated/versions.tsv`.

| | |
|---|---|
| Rôle / raison | Luminosité / XDR de l'écran intégré. |
| Gestion (install, config, MAJ) | Installation manuelle ; MAJ intégrée. |
| Emplacements | Domaine `fyi.lunar.Lunar` — **non capturé** : contient `apiKey`. |
| Dépendances | — |
| Permissions | Accessibilité possible. |
| Démarrage | `startAtLogin = 0`. |

## Paramètres
| Capturés (dans ce dépôt) | Reproductibles (script/commande) | Manuels (procédure) | Inconnus |
|---|---|---|---|
| — | — | Export privé sans clé : `~/.local/share/macos-config-private/lunar/lunar-sans-cle-<date>.plist` ; complet (avec `apiKey`) : `lunar-complet-<date>.plist`. | Usage réel (non lancé, startAtLogin = 0). |

Fichiers capturés : aucun

## Mise à jour
Intégrée.

## Restauration
Lunar quitté : `defaults import fyi.lunar.Lunar <lunar-sans-cle>.plist`, puis ressaisir la clé dans l'app si nécessaire.
