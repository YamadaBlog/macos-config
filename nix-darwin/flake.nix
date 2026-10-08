{
  description = "Targeted Finder/Dock preferences, without managing Nix or Homebrew";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { nix-darwin, ... }: {
    darwinConfigurations.mac = nix-darwin.lib.darwinSystem {
      modules = [ ./darwin.nix ];
    };
  };
}
