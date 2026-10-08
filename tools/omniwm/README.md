# OmniWM

**Statut :** actif — testé (S + I)
Version, provenance : voir `inventory/elements.tsv` et `docs/generated/versions.tsv`.

| | |
|---|---|
| Rôle / raison | Gestionnaire de fenêtres unique : tiling défilant, 4 bureaux étiquetés, règles d'apps, 3 colonnes visibles (1–2 fenêtres remplissent l'écran), aucune marge aux bords. Bordure et barre de bureaux **désactivées par choix de l'utilisateur** (réglages conservés dans `apply-registry.py`). |
| Gestion (install, config, MAJ) | Installation : cask (app + `omniwmctl`). Config : Settings → `settings.toml` ; script `apply-registry.py` (raccourcis AZERTY, bureaux, apparence). MAJ : brew (stable). |
| Emplacements | `~/.config/omniwm/settings.toml` ↔ `tools/omniwm/config/settings.toml`. |
| Dépendances | IPC requis par Hammerspoon. |
| Permissions | Accessibilité + Enregistrement d'écran (accordées, TCC). |
| Démarrage | LaunchAgent HM `org.nix-community.home.omniwm` (`open -g -a OmniWM`). |

## Paramètres
| Capturés (dans ce dépôt) | Reproductibles (script/commande) | Manuels (procédure) | Inconnus |
|---|---|---|---|
| settings.toml complet. | `python3 -I tools/omniwm/apply-registry.py ~/.config/omniwm/settings.toml [--write]` (OmniWM quitté) ; règles : `omniwmctl rule replace …`. | — | Gestes 3 doigts : test physique en attente. |

Fichiers capturés : `config/settings.toml`

## Mise à jour
`brew upgrade --cask omniwm` app quittée ; aperçu `apply-registry.py`.

## Restauration
Quitter ; recopier une sauvegarde `backups/omniwm-*/settings.toml` ; relancer (`launchctl kickstart gui/$(id -u)/org.nix-community.home.omniwm`).

## Mise en page (2026-10-08)
- 3 colonnes visibles ; 1–2 fenêtres remplissent l'écran ; marges 8 px (haut 48 = 40 d'encoche + 8, mesuré depuis le bord physique).
- Fenêtre seule : `singleWindowFit = "1712x1069"` — taille fixe calculée pour l'écran intégré 1728×1117 (Retina 2×, bande du haut 32 pt) ; **à recalculer** pour un écran externe ou une autre résolution (sinon remettre `"fill"`, qui ignore les marges).
- Valeurs possibles (doc officielle) : `"fill"`, `"LARGEURxHAUTEUR"`, `"container_primary_span"`.
