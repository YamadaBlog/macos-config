# Synchroniser le dépôt et le poste

Quatre opérations séparées (scripts dans `scripts/`, données dans `inventory/`) :

| Opération | Sens | Script | Écrit ? |
|---|---|---|---|
| Découverte | poste → liste | `discover.sh` | non |
| Vérification | compare | `verify.sh [--hm]` | non (code 1 si écart) |
| Capture | poste → dépôt | `capture.sh` puis `capture.sh --accept` | oui, après revue |
| Application | dépôt → poste | `apply.sh <id>` puis `--write` | oui, après sauvegarde |

`sync.sh <discover|verify|capture|apply>` est un point d'entrée unique (alias `--check`, `--capture`).

## Garde-fous
- **Capture en deux temps** : la préparation (dans `~/.local/state/macos-power-user-deploy/capture-pending`) affiche les diffs ;
  `--accept` refuse si un fichier cible a des modifications non commitées (la référence n'est jamais écrasée en silence).
  Retour : `git checkout -- <fichier>` ou `git revert`.
- **Secrets** : tout fichier contenant un motif (`token`, `password`, `api_key`, `license`…) est refusé ;
  les plists sont nettoyés (`remote_id`, dates, compteurs, positions de fenêtres).
- **Application** : copie de sauvegarde dans `backups/apply-<date>/<chemin d'origine>` et commande de retour affichée ;
  refus si l'app concernée doit être quittée et tourne encore.
- **Home Manager** : sens unique dépôt → poste (`apply.sh home-manager`) ; ne jamais copier les fichiers générés.

## Routine
Après tout changement de réglage (ou chaque semaine) :
```sh
cd ~/dev/macos-config
scripts/verify.sh                      # que s'est-il passé ?
scripts/capture.sh                     # relire les diffs
scripts/capture.sh --accept
git add -A && git commit -m "capture: …"
# + une ligne dans CHANGELOG.md, + STATUS.md si un statut change
```
Nouvel outil installé : `verify.sh` le signale en « NON INVENTORIÉ » → ajouter sa ligne dans
`inventory/elements.tsv`, sa fiche dans `tools/`, et éventuellement sa config dans `inventory/configs.tsv`.

## Ce qui reste manuel
Raycast (export .rayconfig chiffré), BetterTouchTool (preset), profils Terminal, Lunar (contient une clé),
éléments d'ouverture, permissions TCC — procédures dans les fiches `tools/`.

## Ce que la capture copie — et rien d'autre
Liste fermée : les lignes `file` et `plist` de `inventory/configs.tsv` (11 sources au 2026-10-08), plus le Brewfile
et les instantanés `docs/generated/`. Aucune recherche de fichiers, aucun dossier copié en entier.

**Jamais capturé (exclusions explicites)** : `~/.config/raycast/aster-endpoint.json` (jeton), bases Raycast et BTT,
`~/.claude/` hors `settings.json` (historique, sessions, projets), `~/.claude.json`, `~/.zsh_history`, `~/.zsh_sessions`,
`~/.local/share/atuin`, `~/.ssh`, `~/Library/Application Support/*` (données d'apps), `fyi.lunar.Lunar` (contient `apiKey`),
`io.tailscale.ipn.macsys` (identité réseau), profils Safari/Discord, `~/.local/share/macos-config-private/`.
**Nettoyé à l'export plist** (`scripts/lib.sh`) : `remote_id`, `remote_token`, `device_id`, positions de fenêtres, et pour
Stats/TopNotch les clés de date, compteur, version.
**Refus automatique** : tout fichier contenant `api_key`, `secret`, `password`, `bearer`, `private_key`, `"token"`, `token =`,
`<key>token</key>`, `<key>license…`.
Revue du 2026-10-08 : aucune adresse e-mail, IP ni chemin personnel dans les fichiers capturés ; `settings.json` de Claude Code
contient `defaultMode: bypassPermissions` et une liste d'autorisations (réglage de sécurité, pas un secret).
