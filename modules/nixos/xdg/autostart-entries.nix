{ config, lib, pkgs, ... }:

let
  cfg = config.xdg.autostart;

  xdgDesktopEntrySubmodule = { name, ... }: {
    freeformType = with lib.types; attrsOf anything;
  };
in
{
  options.xdg.autostart.entries = lib.mkOption {
    type = with lib.types; attrsOf (submodule xdgDesktopEntrySubmodule);
    default = { };
    description = ''
      A set of XDG autostart entries to be exported to the environment.
    '';
    example = lib.literalExpression ''
      {
        kando = {
          name = "kando";
          desktopName = "Kando";
          exec = lib.getExe pkgs.kando;
          icon = "kando";
          genericName = "Pie Menu";
        };
      }
    '';
  };

  config = lib.mkIf (cfg.entries != { }) {
    environment.systemPackages =
      let
        mkXDGAutostartFile = _: v:
          pkgs.makeDesktopItem (v // {
            destination = "/etc/xdg/autostart";
          });
      in
      lib.mapAttrsToList mkXDGAutostartFile cfg.entries;
  };
}
