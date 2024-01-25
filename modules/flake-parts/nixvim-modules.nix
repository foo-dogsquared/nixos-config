{ lib, flake-parts-lib, moduleLocation, ... }:

{
  options = {
    flake = flake-parts-lib.mkSubmoduleOptions {
      nixvimModules = lib.mkOption {
        type = with lib.types; lazyAttrsOf unspecified;
        default = { };
        apply = lib.mapAttrs (k: v: {
          _file = "${toString moduleLocation}#nixvimModules.${k}";
          imports = [ v ];
        });
        description = ''
          NixVim modules.

          You may use this to export reusable pieces of plugin configurations,
          plugin modules, etc.
        '';
      };
    };
  };
}
