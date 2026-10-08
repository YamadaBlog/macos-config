# Thème unifié : palette base16 générée à partir du fond d'écran (wallpapers/actuel.png) — voir palette.nix.
# Précédent : « Lune rose » (wallpapers/lune-rose.png, historique Git).
# La palette générée automatiquement par Stylix avait 8 accents roses (erreurs/succès/diff indiscernables) :
# fond et texte viennent de la génération, les accents sont des teintes distinctes prises dans l'image.
# autoEnable = false : seules les cibles listées sont thémées.
{ config, pkgs, lib, ... }:
{
  stylix = {
    enable = true;
    image = ../wallpapers/actuel.png;
    polarity = "dark";
    autoEnable = false;
    # Palette lisible générée depuis l'image par scripts/palette-from-image.py (accents distincts, contraste >= 4,5:1).
    # Régénérée automatiquement quand le fond d'écran change (agent theme-auto) ou par scripts/theme-sync.sh.
    base16Scheme = import ./palette.nix;
    # Police et transparence actuelles de Ghostty conservées (sinon Stylix impose DejaVu et opacité 1).
    fonts.monospace = { package = pkgs.jetbrains-mono; name = "JetBrains Mono"; };
    fonts.sizes.terminal = 13;
    opacity.terminal = 0.94;
    targets = {
      ghostty.enable = true;
      starship.enable = true;
      bat.enable = true;
      fzf.enable = true;
      lazygit.enable = true;
      yazi.enable = true;
      btop.enable = true;
    };
  };

  # Couleurs pour Hammerspoon (alertes des contextes), générées depuis la même palette.
  home.file.".hammerspoon/poweruser-colors.lua".text = let c = config.lib.stylix.colors.withHashtag; in ''
    -- Généré par Home Manager (home-manager/theme.nix) depuis la palette Stylix : ne pas éditer.
    return { bg = "${c.base00}", surface = "${c.base01}", text = "${c.base05}", accent = "${c.base0D}", blue = "${c.base0D}" }
  '';

  # Programmes thémés : gérés par Home Manager (Stylix ne thème que les programmes HM).
  programs.bat.enable = true;
  programs.lazygit.enable = true;
  programs.yazi.enable = true;
  programs.btop.enable = true;
  programs.ghostty = {
    enable = true;
    package = null; # l'app reste installée par Homebrew (cask ghostty)
    settings = {
      window-padding-x = 12;
      window-padding-y = 10;
      background-blur = true;
      # Stylix convertit la taille en px (×4/3 → 17,3) ; Ghostty macOS attend des points : on garde 13.
      font-size = lib.mkForce 13;
    };
  };
}
