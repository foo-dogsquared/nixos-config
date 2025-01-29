# All of the extra module arguments to be passed as part of the home-manager
# environment.
{ pkgs, lib, options, ... }@attrs:

let foodogsquaredLib = import ../../../lib { inherit pkgs; };
in {
  _module.args.foodogsquaredLib = foodogsquaredLib.extend (final: prev:
    {
      home-manager = import ../../../lib/env-specific/home-manager.nix {
        inherit pkgs lib;
        self = final;
      };
    } // lib.optionalAttrs (options ? sops) {
      sops-nix = import ../../../lib/env-specific/sops.nix {
        inherit pkgs lib;
        self = final;
      };
    } // lib.optionalAttrs (attrs ? nixosConfig) {
      nixos = import ../../../lib/env-specific/nixos.nix {
        inherit pkgs lib;
        self = final;
      };
    });
}
