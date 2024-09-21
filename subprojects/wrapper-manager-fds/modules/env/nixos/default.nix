{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.wrapper-manager;
  wmDocs = import ../../../docs { inherit pkgs; inherit (cfg.documentation) extraModules; };
in
{
  imports = [ ../common.nix ];

  config = lib.mkMerge [
    {
      environment.systemPackages =
        lib.optionals cfg.documentation.manpage.enable [ wmDocs.outputs.manpage ]
        ++ lib.optionals cfg.documentation.html.enable [ wmDocs.outputs.html ];

      wrapper-manager.extraSpecialArgs.nixosConfig = config;

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
    }

    (lib.mkIf (cfg.packages != { }) {
      environment.systemPackages =
        lib.mapAttrsToList (_: wrapper: wrapper.build.toplevel) cfg.packages;
    })
  ];
}
