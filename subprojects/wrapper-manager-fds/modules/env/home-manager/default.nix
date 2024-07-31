{
  config,
  lib,
  pkgs,
  ...
}@moduleArgs:

let
  cfg = config.wrapper-manager;
  wmDocs = import ../../../docs { inherit pkgs; };
in
{
  imports = [ ../common.nix ];

  config = lib.mkMerge [
    {
      home.packages =
        lib.optionals cfg.documentation.manpage.enable [ wmDocs.outputs.manpage ]
        ++ lib.optionals cfg.documentation.html.enable [ wmDocs.outputs.html ];

      wrapper-manager.extraSpecialArgs.hmConfig = config;
    }

    (lib.mkIf (moduleArgs ? nixosConfig) {
      wrapper-manager.sharedModules = [
        (
          { lib, ... }:
          {
            # NixOS already has the option to set the locale so we don't need to
            # have this.
            config.locale.enable = lib.mkDefault false;
          }
        )
      ];
    })

    (lib.mkIf (cfg.packages != { }) {
      home.packages = lib.mapAttrsToList (_: wrapper: wrapper.build.toplevel) cfg.packages;
    })
  ];
}
