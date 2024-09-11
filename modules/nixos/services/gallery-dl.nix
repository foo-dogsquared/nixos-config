{ config, lib, pkgs, options, ... }:

let
  cfg = config.services.gallery-dl;

  jobUnitName = name: "gallery-dl-archive-job-${name}";

  settingsFormat = pkgs.formats.json { };
  settingsFormatFile =
    settingsFormat.generate "gallery-dl-service-config" cfg.settings;

  jobType = { name, config, ... }: {
    options = {
      urls = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
        description = ''
          A list of URLs to be downloaded to {command}`gallery-dl`. Please
          see the list of extractors with `--list-extractors`.
        '';
        example = lib.literalExpression ''
          [
            "https://www.deviantart.com/xezeno"
            "https://www.pixiv.net/en/users/60562229"
          ]
        '';
      };

      startAt = lib.mkOption {
        type = with lib.types; str;
        description = ''
          Indicates how frequent the download will occur. The given schedule
          should follow the format as described from
          {manpage}`systemd.time(5)`.
        '';
        default = "daily";
        example = "*-*-3/4";
      };

      downloadPath = options.services.gallery-dl.downloadPath // {
        default = cfg.downloadPath;
      };

      extraArgs = lib.mkOption {
        type = with lib.types; listOf str;
        description = ''
          Job-specific extra arguments to be passed to the
          {command}`gallery-dl`.
        '';
        default = [ ];
        example = lib.literalExpression ''
          [
            "--date" "today-1week" # get only videos from a week ago
            "--output" "%(uploader)s/%(title)s.%(ext)s" # download them in the respective directory
          ]
        '';
      };

      settings = options.services.gallery-dl.settings // {
        description = ''
          Job-specific settings to be overridden to the service-wide settings
          (if there's any).
        '';
        default = { };
      };
    };

    config = {
      extraArgs = cfg.extraArgs;
      settings = cfg.settings;
    };
  };
in
{
  options.services.gallery-dl = {
    enable = lib.mkEnableOption "archiving services with gallery-dl";

    package = lib.mkOption {
      type = lib.types.package;
      description =
        "Package containing the {command}`gallery-dl` binary.";
      default = pkgs.gallery-dl;
      defaultText = lib.literalExpression "pkgs.gallery-dl";
    };

    downloadPath = lib.mkOption {
      type = lib.types.str;
      description = ''
        The default download path of the entire jobset (which can easily be
        overriden).
      '';
      default = "/var/gallery-dl";
      example = "/var/archives/gallery-dl-service";
    };

    settings = lib.mkOption {
      type = settingsFormat.type;
      description = ''
        The configuration to be used for the service. If the value is empty,
        the service will not pass any option relating to the custom
        configuration.
      '';
      default = null;
      example = lib.literalExpression ''
        {
          cache.file = "~/.gallery-dl-cache.sqlite3";
          extractor.directory = [ "{category}" "{user|artist|uploader}" ];
        }
      '';
    };

    extraArgs = lib.mkOption {
      type = with lib.types; listOf str;
      description = ''
        Global list of arguments to be passed to each gallery-dl download jobs.
      '';
      default = [ ];
      example = lib.literalExpression ''
        [
          "--retries 20"
        ]
      '';
    };

    jobs = lib.mkOption {
      type = with lib.types; attrsOf (submodule jobType);
      description = ''
        A map of jobs for the archiving service.
      '';
      default = { };
      example = lib.literalExpression ''
        {
          arts = {
            urls = [
              "https://www.pixiv.net/en/users/60562229"
              "https://www.deviantart.com/xezeno"
            ];
            startAt = "weekly";
          };

          mango = {
            urls = [
              # TODO: Put some manga sites here
            ];
            startAt = "weekly";
          };
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services = lib.mapAttrs'
      (name: value:
        lib.nameValuePair (jobUnitName name) {
          wantedBy = [ "multi-user.target" ];
          description = "gallery-dl archive job for group '${name}'";
          documentation = [ "man:gallery-dl(1)" ];
          enable = true;
          path = with pkgs; [ brotli ffmpeg cfg.package ];
          preStart = ''
            mkdir -p ${lib.escapeShellArg value.downloadPath}
          '';

          # Order matters here. We're letting service-level arguments and
          # settings to be overridden with job-specific things as much as
          # possible especially with the settings.
          #
          # Regarding to settings (`settings`) and extra arguments
          # (`extraArgs`), the settings is the last applied argument with
          # `--config` option. This means that it will cascade resultings
          # settings from `extraArgs` if there's any related option that is
          # given like another `--config` for example.
          script =
            let
              jobLevelSettingsFile =
                settingsFormat.generate "gallery-dl-job-${name}-settings"
                  value.settings;
            in
            ''
              gallery-dl ${lib.escapeShellArgs value.extraArgs} ${
                lib.optionalString (value.settings != null)
                "--config ${jobLevelSettingsFile}"
              } --destination ${lib.escapeShellArg value.downloadPath} ${
                lib.escapeShellArgs value.urls
              }
            '';
          startAt = value.startAt;
          serviceConfig = {
            LockPersonality = true;
            NoNewPrivileges = true;
            PrivateTmp = true;
            PrivateUsers = true;
            PrivateDevices = true;
            ProtectControlGroups = true;
            ProtectClock = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            SystemCallFilter = "@system-service";
            SystemCallErrorNumber = "EPERM";
          };
        })
      cfg.jobs;

    systemd.timers = lib.mapAttrs'
      (name: value:
        lib.nameValuePair (jobUnitName name) {
          timerConfig = {
            Persistent = true;
            RandomizedDelaySec = "2min";
          };
        })
      cfg.jobs;
  };
}
