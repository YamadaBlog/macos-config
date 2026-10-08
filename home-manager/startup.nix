# Démarrage à l'ouverture de session : UN mécanisme par outil (LaunchAgent géré ici).
# Raycast garde son propre élément d'ouverture (enregistré par l'app) : ne pas le dupliquer ici.
# open -a ne lance jamais une seconde instance d'une app déjà ouverte.
{ config, pkgs, ... }:
let
  logs = "${config.home.homeDirectory}/Library/Logs/macos-config";
  openApp = name: {
    enable = true;
    config = {
      ProgramArguments = [ "/usr/bin/open" "-g" "-a" name ];
      RunAtLoad = true;
      ProcessType = "Interactive";
    };
  };
  # Rotation « copier puis tronquer » : le fichier reste ouvert par launchd/Neru (O_APPEND vérifié),
  # donc on ne le déplace pas (Neru continuerait d'écrire dans l'archive). Archive = 1 Mo de fin
  # au maximum ; stockage borné à ~1 Mo d'archive + croissance pendant 10 min, par journal.
  logRotate = pkgs.writeShellScript "macos-config-logrotate" ''
    umask 077
    for f in "${logs}"/*.log; do
      [ -f "$f" ] || continue
      /bin/chmod 600 "$f"
      if [ "$(/usr/bin/stat -f %z "$f")" -gt 1048576 ]; then
        /usr/bin/tail -c 1048576 "$f" > "$f.1" && : > "$f"
        /bin/chmod 600 "$f.1"
      fi
    done
    exit 0
  '';
in {
  launchd.agents = {
    # Gestionnaire de fenêtres : OmniWM (AeroSpace et placement natif essayés le 2026-10-09 puis abandonnés).
    omniwm = openApp "OmniWM";
    hammerspoon = openApp "Hammerspoon";
    stats = openApp "Stats";
    neru = {
      enable = true;
      config = {
        # Binaire lancé DIRECTEMENT : via un script intermédiaire, Neru réinitialise sa propre
        # autorisation Accessibilité (incident du 2026-10-08 15:31). Pas de lanceur bash ici.
        ProgramArguments = [ "/Applications/Neru.app/Contents/MacOS/neru" "launch" ];
        RunAtLoad = true;
        # Relance seulement après un arrêt anormal ; SIGTERM / Quitter (code 0) n'est pas relancé.
        KeepAlive = { SuccessfulExit = false; };
        # Panne persistante : au plus 2 relances/min (launchd n'a pas de plafond de relances) ;
        # arrêt durable : launchctl bootout gui/$(id -u)/org.nix-community.home.neru
        ThrottleInterval = 30;
        ProcessType = "Interactive";
        StandardOutPath = "${logs}/neru.log";
        StandardErrorPath = "${logs}/neru.log";
      };
    };
    # Thème : régénéré quand macOS change de fond d'écran (index des fonds surveillé) ; sans effet si l'image n'a pas changé.
    theme-auto = {
      enable = true;
      config = {
        ProgramArguments = [ "/bin/bash" "${config.home.homeDirectory}/dev/macos-config/scripts/theme-auto.sh" ];
        WatchPaths = [ "${config.home.homeDirectory}/Library/Application Support/com.apple.wallpaper/Store/Index.plist" ];
        ThrottleInterval = 20;
        ProcessType = "Background";
      };
    };
    logrotate = {
      enable = true;
      config = {
        ProgramArguments = [ "${logRotate}" ];
        RunAtLoad = true;
        StartInterval = 600; # toutes les 10 min (coût négligeable : un stat par journal)
        ProcessType = "Background";
      };
    };
  };
  home.file."Library/Logs/macos-config/.keep".text = "";
}
