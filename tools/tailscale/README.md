# Tailscale

**Statut :** actif — testé (status)
Version, provenance : voir `inventory/elements.tsv` et `docs/generated/versions.tsv`.

| | |
|---|---|
| Rôle / raison | VPN maillé. |
| Gestion (install, config, MAJ) | pkg standalone (`com.tailscale.ipn.macsys`) ; MAJ intégrée. |
| Emplacements | Privé : prefs `io.tailscale.ipn.macsys`, identité réseau. CLI `/usr/local/bin/tailscale` (installé par l'app). |
| Dépendances | Compte Tailscale. |
| Permissions | Extension réseau `io.tailscale.ipn.macsys.network-extension` (activée). |
| Démarrage | Probable (app). |

## Paramètres
| Capturés (dans ce dépôt) | Reproductibles (script/commande) | Manuels (procédure) | Inconnus |
|---|---|---|---|
| — | — | Connexion au compte. | — |

Fichiers capturés : aucun

## Mise à jour
Intégrée.

## Restauration
Se reconnecter.
