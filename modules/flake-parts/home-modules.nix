{ lib, flake-parts-lib, moduleLocation, ... }:

{
  options = {
    flake = flake-parts-lib.mkSubmoduleOptions {
      homeModules = lib.mkOption {
        type = with lib.types; lazyAttrsOf unspecified;
        default = { };
        apply = lib.mapAttrs (k: v: {
          _file = "${toString moduleLocation}#homeModules.${k}";
          imports = [ v ];
        });
        description = ''
          home-manager modules.

          You may use this to export reusable pieces of configuration, service
          modules, etc.
        '';
      };
    };
  };
}
