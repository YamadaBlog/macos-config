{ lib, ... }:
let profile = import ./profile.nix;
in lib.mkIf profile.enableShell {
  programs.zsh.enable = true;
  programs.zsh.shellAliases.ll = "ls -lah";
  # Migrated from the old ~/.zprofile (Homebrew) and ~/.zshrc (~/.local/bin: Claude Code).
  programs.zsh.profileExtra = ''
    eval "$(/opt/homebrew/bin/brew shellenv zsh)"
  '';
  home.sessionPath = [ "$HOME/.local/bin" ];
  programs.fzf = {
    enable = true;
    # Atuin owns Ctrl-R when enabled; fzf remains available as a CLI.
    enableZshIntegration = !profile.enableAtuin;
  };
  programs.zoxide = { enable = true; enableZshIntegration = true; };
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      character.success_symbol = "[❯](bold blue)";
      character.error_symbol = "[❯](bold red)";
    };
  };
  programs.atuin = lib.mkIf profile.enableAtuin {
    enable = true;
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ];
    settings = { auto_sync = false; update_check = false; };
  };
  programs.direnv = lib.mkIf profile.enableDev {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
