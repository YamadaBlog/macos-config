# Claude Code

**Statut :** actif
Version, provenance : voir `inventory/elements.tsv` et `docs/generated/versions.tsv`.

| | |
|---|---|
| Rôle / raison | Agent IA en terminal (outil principal de travail). |
| Gestion (install, config, MAJ) | Installation : installateur natif. MAJ : intégrée. Config : `settings.json`. |
| Emplacements | `~/.claude/settings.json` ↔ `tools/claude-code/config/settings.json`. Privé : `~/.claude.json`, `~/.claude/{history.jsonl,projects,sessions,shell-snapshots,plugins,...}`. Binaire : `~/.local/bin/claude` → `~/.local/share/claude/versions/`. App `~/Applications/Claude Code URL Handler.app`. |
| Dépendances | `~/.local/bin` dans le PATH (Home Manager). |
| Permissions | Celles du terminal hôte. |
| Démarrage | — |

## Paramètres
| Capturés (dans ce dépôt) | Reproductibles (script/commande) | Manuels (procédure) | Inconnus |
|---|---|---|---|
| `settings.json` (modèle, thème, permissions). | — | Connexion (`/login`) ; marketplace `claude-plugins-official` connue, aucun plugin installé détecté. | — |

Fichiers capturés : `config/settings.json`

## Mise à jour
Auto.

## Restauration
Recopier `settings.json` ; se reconnecter.
