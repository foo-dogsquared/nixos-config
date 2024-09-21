{ lib, flake-parts-lib, inputs, ... }:

{
  options = {
    flake = flake-parts-lib.mkSubmoduleOptions {
      diskoConfigurations = lib.mkOption {
        type = with lib.types; attrsOf (inputs.disko.lib.topLevel);
        default = { };
        description = ''
          A set of [disko](https://github.com/nix-community/disko)
          configurations readily available as part of the flake output to be
          used by {command}`disko`. Could be useful as backup initialization
          scripts for individual storage drives.
        '';
      };
    };
  };
}
