{ config, lib, pkgs, ... }:

let
  cfg = config.programs.dwarf-fortress;
in
{
  options.programs.dwarf-fortress = {
    enable = lib.mkEnableOption "managing Dwarf Fortress through the nixpkgs opinionated wrapper";

    package = lib.mkPackageOption pkgs "dwarf-fortress-full" { };

    wrapperSettings = lib.mkOption {
      type = with lib.types; attrsOf anything;
      default = { };
      description = ''
        Settings for the opinionated wrapper to be applied to the package.
      '';
      example = {
        dfVersion = "0.44.11";
        theme = "cla";
        enableIntro = false;
        enableFPS = true;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = lib.singleton (cfg.package.override cfg.wrapperSettings);
  };
}
