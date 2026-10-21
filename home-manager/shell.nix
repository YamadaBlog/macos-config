{ lib, ... }:
let profile = import ./profile.nix;
in lib.mkIf profile.enableShell {
  programs.zsh.enable = true;
  programs.zsh.shellAliases.ll = "ls -lah";
  # Second Claude Code account: separate config dir (login, settings); plain `claude` keeps ~/.claude.
  # env -u: a Ghostty started from a Claude session leaks its child marker, which turns transcript saving off.
  # BROWSER: its links (artifacts, login) open in Chrome, signed in to the second account; `claude` keeps Safari.
  programs.zsh.shellAliases.claude2 = "env -u CLAUDECODE -u CLAUDE_CODE_CHILD_SESSION -u CLAUDE_CODE_ENTRYPOINT -u CLAUDE_CODE_SESSION_ID CLAUDE_CONFIG_DIR=$HOME/.claude-2 BROWSER=$HOME/.local/bin/open-in-chrome claude";
  home.file.".local/bin/open-in-chrome" = {
    executable = true;
    text = ''
      #!/bin/sh
      # Hands the URL to the running Chrome (or starts it) in its default profile.
      exec "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --profile-directory=Default "$@" >/dev/null 2>&1 &
    '';
  };
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
