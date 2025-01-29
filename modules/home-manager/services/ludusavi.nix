{ config, lib, pkgs, ... }:

let
  cfg = config.services.ludusavi;

  settingsFormat = pkgs.formats.yaml { };

  configFile = if cfg.configFile == null then
    settingsFormat.generate "ludusavi-service-config" cfg.settings
  else
    cfg.configFile;
in {
  options.services.ludusavi = {
    enable = lib.mkEnableOption "Ludusavi game backup";

    package = lib.mkPackageOption pkgs "ludusavi" { };

    settings = lib.mkOption {
      type = settingsFormat.type;
      description = ''
        The configuration for the backup service. If
        {option}`services.ludusavi.configFile` contains a non-null value, this
        option is effectively ignored.
      '';
      default = { };
      example = lib.literalExpression ''
        {
          manifest.url = "https://raw.githubusercontent.com/mtkennerly/ludusavi-manifest/master/data/manifest.yaml";
          backup.path = "''${config.xdg.cacheHome}/ludusavi/backups";
          restore.path = "''${config.xdg.cacheHome}/ludusavi/backups";
        }
      '';
    };

    extraArgs = lib.mkOption {
      type = with lib.types; listOf str;
      description = ''
        Extra arguments to be passed to the game backup service.
      '';
      default = [ "--force" ];
      example = [ "--force" "--compression" "zstd" "--compression-level" "13" ];
    };

    startAt = lib.mkOption {
      type = lib.types.str;
      description = ''
        How often the backup occurs.

        The value is used to `Calendar.OnCalendar` systemd timer option. For
        more details about the value format, see {manpage}`systemd.time(7)`.
      '';
      default = "daily";
      example = "weekly";
    };

    configFile = lib.mkOption {
      type = with lib.types; nullOr path;
      description = ''
        The path of the configuration file to be used for the game backup
        service. If this is set to `null`, it will generate one from
        {option}`services.ludusavi.settings`.
      '';
      default = null;
      example = lib.literalExpression "./config/ludusavi/config.yaml";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "services.ludusavi" pkgs
        lib.platforms.linux)
    ];

    # We're putting it somewhere in the home directory instead of the typical
    # Nix store directory since the configuration directory has to be writable
    # for the manifest file.
    xdg.dataFile."ludusavi/hm-service-config.yaml".source = configFile;

    systemd.user.services.ludusavi = {
      Unit = {
        Description = "Periodic game backup";
        Documentation = [ "https://github.com/mtkennerly/ludusavi" ];

        After = [ "network-online.target" "default.target" ];
      };

      Service = {
        ExecStart = "${
            lib.getExe' cfg.package "ludusavi"
          } --config ${config.xdg.dataHome}/ludusavi/hm-service-config.yaml backup ${
            lib.concatStringsSep " " cfg.extraArgs
          }";
        Restart = "on-failure";
      };
    };

    systemd.user.timers.ludusavi = {
      Unit.Description = "Periodic game backup";
      Timer = {
        Persistent = true;
        OnCalendar = cfg.startAt;
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
