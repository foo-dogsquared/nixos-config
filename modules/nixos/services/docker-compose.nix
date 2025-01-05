{ config, lib, pkgs, utils, ... }:

let
  cfg = config.services.docker-compose;

  settingsFormat = pkgs.formats.yaml { };

  jobModule = { name, lib, config, ... }: {
    options = {
      extraArgs = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
        description = ''
          Job-specific set of arguments to be added to {command}`docker compose`.
        '';
      };

      files = lib.mkOption {
        type = with lib.types; listOf path;
        description = ''
          List of files to be used when setting up the docker-compose service.
        '';
        default = [];
        example = lib.literalExpression ''
          [
            /path/to/docker-compose.yml
          ]
        '';
      };

      settings = lib.mkOption {
        type = settingsFormat.type;
        description = ''
          Configuration to be used for the docker-compose process.
        '';
        default = { };
        example = {
        };
      };
    };

    config = {
      extraArgs =
        cfg.extraArgs
        ++ lib.concatMap (f: [ "--file" f ]) config.files;

      files = lib.optionals (config.settings != { }) [
        (settingsFormat.generate "docker-compose-generated-${name}" config.settings)
      ];
    };
  };

  mkDockerComposeService = name: value:
    lib.nameValuePair "docker-compose-${utils.escapeSystemdPath name}" {
      path = [ config.virtualisation.docker.package ];
      script = "docker compose --project-name ${name} up";
      postStop = "docker compose --project-name ${name} down";

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };
in
{
  options.services.docker-compose = {
    enable = lib.mkEnableOption "integration with docker-compose";

    extraArgs = lib.mkOption {
      type = with lib.types; listOf str;
      default = [];
    };

    jobs = lib.mkOption {
      type = with lib.types; attrsOf (submodule jobModule);
      default = { };
      description = ''
        A jobset of Docker compose services to be integrated with the system.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = lib.singleton {
      assertion = cfg.enable && config.virtualisation.docker.enable;
      message = "Docker server is not enabled.";
    };

    systemd.services = lib.mapAttrs' mkDockerComposeService cfg.jobs;
  };
}
