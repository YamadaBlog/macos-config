# Shared defaults; ~/.config/macos-config/profile.local.nix (outside the repo, optional) overrides them,
# e.g. { lockDown = true; }. Read at build time: scripts/apply.sh evaluates with --impure.
let
  local = builtins.getEnv "HOME" + "/.config/macos-config/profile.local.nix";
in {
  # Deploy the CLIs first; take over the shell after backup and comparison.
  enableShell = true;
  enableAtuin = true;
  enableTui = true;
  enableDev = false;
  enableRestic = false;
  enableSync = false;
  # F3/F4 do nothing (Hammerspoon) and the Dock never shows.
  lockDown = false;
} // (if builtins.pathExists local then import local else { })
