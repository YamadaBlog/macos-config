# Séance de tests humains (≈ 10 min, une seule fois)

Avant : enregistrer le travail ouvert. Répondre à l'assistant avec le numéro et **OK** ou **KO + ce qui s'est passé**.
Aucun de ces tests n'est marqué réussi sans ce retour.

| # | Faire | Résultat attendu |
|---|---|---|
| 1 | Dans Notes (ou Ghostty), taper `@ | \ { } [ ] ~` puis `é è à ç ù`, puis `^` + `e`, `¨` + `e`, puis Option+Espace | tous les caractères apparaissent ; `ê`, `ë` ; une espace insécable ; aucune fenêtre ne bouge |
| 2 | Bureau Focus (Ctrl+1) : glisser **3 doigts horizontalement** | les colonnes de fenêtres défilent |
| 3 | Safari (Ctrl+2) : défiler la page à **2 doigts** | la page défile, pas les colonnes |
| 4 | 3 doigts vers le haut ; **4 doigts** gauche/droite | Mission Control ; changement de bureau OmniWM (un seul effet chacun) |
| 5 | Ctrl+1, Ctrl+2, Ctrl+3, Ctrl+4 | bureaux Focus, Web, Messages, Atelier |
| 6 | Sur une fenêtre : Ctrl+Shift+3, puis Ctrl+3, puis Ctrl+Shift+1 ; ensuite Option+Tab | la fenêtre part sur Messages puis revient sur Focus ; Option+Tab ramène à la fenêtre précédente |
| 7 | Hyper+O, puis Échap | Overview des bureaux, puis retour |
| 8 | Hyper+P → choisir « Web », puis Hyper+P → « Focus » | bascule sur Web (Safari), puis sur Focus |
| 9 | Hyper+N dans Safari, taper deux lettres d'un hint | clic sur l'élément choisi |
| 10 | Nouvelle fenêtre Ghostty (Cmd+N) : `rg --version`, Ctrl-R, sélectionner du texte + Cmd+C, Cmd+V | version affichée ; historique Atuin ; copier-coller OK ; texte lisible malgré la transparence |
| 11 | Cmd+Espace → « Dépôt » → Entrée ; copier un texte puis Cmd+Espace → « Clipboard History » | le dépôt s'ouvre ; le texte copié est en tête |
| 12 | Fermer l'écran 1 min, rouvrir, puis Ctrl+2, Hyper+N, Hyper+P | les trois réagissent |

## Après la séance (avec autorisation explicite seulement)
**Déconnexion** puis **redémarrage** : voir « Reprise » ci-dessous. Ne pas lancer tant que l'assistant n'a pas confirmé
que les instructions de reprise sont prêtes.

### Reprise après déconnexion ou redémarrage
1. Se reconnecter, attendre ~30 s.
2. Ouvrir Terminal ou Ghostty et lancer : `~/dev/macos-config/scripts/post-session-check.sh`
3. Rouvrir l'assistant (Claude Code) dans `~/dev/macos-config` et lui coller la sortie, ou lui dire « reprends » :
   l'état est dans `STATUS.md` et `~/.local/state/macos-power-user-deploy/resume.txt`.
