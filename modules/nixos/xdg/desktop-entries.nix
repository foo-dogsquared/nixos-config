{ config, lib, pkgs, ... }:

let
  cfg = config.xdg.desktopEntries;

  xdgDesktopEntrySubmodule = { name, ... }: {
    freeformType = with lib.types; attrsOf anything;
    options = {
      name = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = name;
        description = ''
          Filename of the desktop entry.
        '';
        example = "hello";
      };
    };
  };
in
{
  options.xdg.desktopEntries = lib.mkOption {
    type = with lib.types; attrsOf (submodule xdgDesktopEntrySubmodule);
    default = { };
    description = ''
      A set of XDG desktop entries to be exported as part of the applications
      list (i.e., {file}`$out/share/applications`) to the environment.
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

  config = lib.mkIf (cfg != { }) {
    environment.systemPackages =
      let
        mkXDGDesktopEntry = _: v:
          pkgs.makeDesktopItem (v // {
            destination = "/share/applications";
          });
      in
      lib.mapAttrsToList mkXDGDesktopEntry cfg;
  };
}

