# Debloat (préexistant)

- Outil : `~/Tools/mac-os-debloat` — https://github.com/OleksandrKrupko/mac-os-debloat, version 0.13.2 (commit e3a8fa8).
- Preset : `dev-minimal` (142 libellés), copie dans `~/.mac-os-debloat/presets/` ; dernier état : `~/.mac-os-debloat/latest.json`.
- Overrides launchctl observés : 153 au prévol, 154 ensuite, 153 depuis 17:52 : `com.apple.FolderActionsDispatcher` désactivé puis réactivé, puis de nouveau désactivé (18:0x) après un simple `osascript … quit app` : il **bascule lors d'appels `osascript`** (mécanisme exact non établi) ; sans incidence, exclu du décompte suivi.
- SIP désactivé : les overrides persistent sans daemon de réapplication.

## Effets constatés
| Fonction | État | Cause |
|---|---|---|
| Spotlight / recherche | OK | — |
| Presse-papiers | OK | — |
| Tailscale / réseau | OK | — |
| Raccourcis (Shortcuts) | **KO** « Couldn't communicate with a helper application » | `com.apple.siriactionsd` désactivé |
| Dictée | non testée ; probablement affectée | `com.apple.corespeechd` désactivé |
| Achat/téléchargement App Store (Xcode) | **KO** : `NSCocoaErrorDomain 4099`, connexion à `com.apple.xpc.amsengagementd` invalidée | `com.apple.amsengagementd` désactivé → **réactivé le 2026-10-08** (gui/501, ciblé) |

Correctif ciblé et réversible (non appliqué, ton choix de debloat est respecté) :
`launchctl enable gui/501/com.apple.siriactionsd` — retour : `launchctl disable gui/501/com.apple.siriactionsd`.
Ne pas faire de nouveau debloat ni de restauration globale depuis ce dépôt ; l'outil fournit `debloat --restore` / `--enable-all`.

## Services de diagnostic désactivés (relevé du 2026-10-08, lecture seule)
analyticsd, analyticsagent, audioanalyticsd, ecosystemanalyticsd, geoanalyticsd, inputanalyticsd, wifianalyticsd,
diagnosticservicesd, diagnosticextensionsd, diagnostics_agent, diagnosticspushd, DiagnosticsReporter, SubmitDiagInfo,
symptomsd-diag, symptomsd.distributed-agent, systemstats.{analysis,daily,microstackshot_periodic}, signpost_reporter,
rtcreportingd, feedbackd, appleseed.{fbahelperd,seedusaged}, InstallerDiagnostics.*, Biome (BiomeAgent, biomed, biomesyncd).

| Conséquence | Observé | Preuve |
|---|---|---|
| Journal unifié | **fonctionne** (`logd` actif) | message `logger` relu avec `/usr/bin/log show` |
| Rapports de plantage des apps | **absents** pour l'arrêt de Neru (dossier utilisateur vide depuis le 7 oct.) | `~/Library/Logs/DiagnosticReports` ; quelques rapports système existent encore dans `/Library/Logs/DiagnosticReports` |
| Statistiques système, analyses d'usage | non produites (attendu) | — |
| Feedback Assistant / bêta Apple | indisponibles (attendu) | — |

Options si un diagnostic de plantage devient nécessaire (aucune appliquée) :
1. Réactiver temporairement et **ciblé** : `launchctl enable gui/501/com.apple.diagnosticservicesd` (et/ou `system/…` avec admin), reproduire, puis `launchctl disable …`.
2. Passer par l'outil d'origine : `debloat` (réactivation d'un service précis) — pas de `--restore` global.
3. Sans rien réactiver : lancer l'app suspecte au premier plan dans un terminal pour lire sa sortie, et consulter `/usr/bin/log`.

## Exceptions appliquées (réparations ciblées)
| Service | Raison | Retour |
|---|---|---|
| `com.apple.talagent` (gui/501) | **Do NOT re-enable.** Tried 2026-10-09: talagentd started but never answered `com.apple.window_proxies`; System Settings and app switching froze system-wide (hang report: blocked waiting for talagentd). Disabled again. | — |
| `com.apple.amsengagementd` (gui/501) | achats App Store en échec (Xcode) | `launchctl disable gui/501/com.apple.amsengagementd; launchctl bootout gui/501/com.apple.amsengagementd` |
