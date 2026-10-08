{ ... }:
let identity = import ./identity.nix;
in {
  assertions = [
    { assertion = identity.username != "A_COMPLETER";
      message = "Fill in nix-darwin/identity.nix before building."; }
    { assertion = identity.homeDirectory == "/Users/${identity.username}";
      message = "Check the account path; adapt the assertion for a custom path."; }
  ];
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 6;
  system.primaryUser = identity.username;
  users.users.${identity.username}.home = identity.homeDirectory;
  # The daemon stays owned by the existing installation/Lix.
  nix.enable = false;
  homebrew.enable = false;
  # These preferences do not cover every effect of nix-darwin activation.
  system.defaults = {
    finder = { ShowPathbar = true; ShowStatusBar = true; AppleShowAllExtensions = true; };
    # tilesize = actual value recorded on 2026-10-08
    dock = { autohide = true; tilesize = 43; mru-spaces = false; };
  };
}
