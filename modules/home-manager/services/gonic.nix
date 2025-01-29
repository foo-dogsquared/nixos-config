{ config, lib, pkgs, ... }:

let
  cfg = config.services.gonic;

  settingsFormat = pkgs.formats.keyValue {
    mkKeyValue = lib.generators.mkKeyValueDefault { } " ";
    listsAsDuplicateKeys = true;
  };
  settingsFile = settingsFormat.generate "gonic-settings-config" cfg.settings;
in {
  options.services.gonic = {
    enable = lib.mkEnableOption "Gonic, a Subsonic-compatible music server";

    package = lib.mkPackageOption pkgs "gonic" { };

    settings = lib.mkOption {
      type = settingsFormat.type;
      default = { };
      description = ''
        Configuration to be included to the service.
      '';
      example = lib.literalExpression ''
        {
          music-path = [ config.xdg.userDirs.music ];
          podcast-path = [ "''${config.xdg.userDirs.music}/Podcasts" ];
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "services.gonic" pkgs
        lib.platforms.linux)
    ];

    systemd.user.services.gonic = {
      Unit = {
        Description = "Gonic media server";
        Documentation = [ "https://github.com/sentriz/gonic/wiki" ];
        After = [ "network-online.target" ];
      };

      Service = {
        ExecStart =
          "${lib.getExe' cfg.package "gonic"} -config-path ${settingsFile}";
        Restart = "on-failure";
      };

      Install.WantedBy = [ "default.target" ];
    };
  };
}
