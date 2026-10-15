# Machine-specific values, read from the environment at build time: nothing personal is stored here.
# Requires an impure evaluation; scripts/apply.sh runs:
#   MACOS_CONFIG_REPO=<clone> nix build --impure '.#homeConfigurations.mac.activationPackage'
let
  env = builtins.getEnv;
  need = name: let v = env name; in
    if v == "" then throw "${name} is empty: build through scripts/apply.sh home-manager (it passes --impure and MACOS_CONFIG_REPO)." else v;
in {
  username = need "USER";
  homeDirectory = need "HOME";
  repoDir = need "MACOS_CONFIG_REPO";
}
