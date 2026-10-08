{
  description = "Apple Silicon macOS base: CLI, shell and theme (Home Manager)";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # base16 theme generated from the wallpaper (wallpapers/actuel.png); stable branch aligned with 26.05.
    stylix.url = "github:nix-community/stylix/release-26.05";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { nixpkgs, home-manager, stylix, ... }: {
    homeConfigurations.mac = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { system = "aarch64-darwin"; };
      modules = [ stylix.homeModules.stylix ./home.nix ];
    };
  };
}
