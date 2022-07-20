{ config, options, lib, pkgs, ... }:

let
  cfg = config.services.gallery-dl;

  settingsFormat = pkgs.formats.json { };
  settingsFormatFile =
    settingsFormat.generate "gallery-dl-service-config" cfg.settings;

  jobType = { name, config, options, ... }: {
    options = {
      urls = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
        description = ''
          A list of URLs to be downloaded to <command>gallery-dl</command>. Please
          see the list of extractors with <option>--list-extractors</option>.
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
          <citerefentry>
            <refentrytitle>systemd.time</refentrytitle>
            <manvolnum>5</manvolnum>
          </citerefentry>.
        '';
        default = "daily";
        example = "*-*-3/4";
      };

      extraArgs = lib.mkOption {
        type = with lib.types; listOf str;
        description = ''
          Job-specific extra arguments to be passed to the
          <command>gallery-dl</command>.
        '';
        default = [ ];
        example = lib.literalExpression ''
          [
            "--date 'today-1week'" # get only videos from a week ago
            "--output '%(uploader)s/%(title)s.%(ext)s'" # download them in the respective directory
          ]
        '';
      };

      settings = lib.mkOption {
        type = settingsFormat.type;
        description = ''
          Job-specific settings to be overridden to the service-wide settings.
        '';
        default = { };
        example = lib.literalExpression ''
          {
            extractor.directory = [ "{category}" "{user|artist|uploader}" ];
          }
        '';
      };
    };
  };
in {
  options.services.gallery-dl = {
    enable = lib.mkEnableOption "archiving services with gallery-dl";

    package = lib.mkOption {
      type = lib.types.package;
      description =
        "Package containing the <command>gallery-dl</command> binary.";
      default = pkgs.gallery-dl;
      defaultText = lib.literalExpression "pkgs.gallery-dl";
    };

    archivePath = lib.mkOption {
      type = lib.types.str;
      description = ''
        The location of the archive to be downloaded. Take note it is assumed
        to be created at the time of running the service.
      '';
      default = "/archives/gallery-dl-service";
      example = lib.literalExpression "/var/archives/gallery-dl-services";
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
        }
      '';
    };

    extraArgs = lib.mkOption {
      type = with lib.types; listOf str;
      description =
        "List of arguments to be passed to <command>gallery-dl</command>.";
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
    systemd.services = lib.mapAttrs' (name: value:
      lib.nameValuePair "gallery-dl-archive-service-${name}" {
        after = [ "network.target" ];
        description = "gallery-dl archive job for group '${name}'";
        documentation = [ "man:gallery-dl(1)" ];
        enable = true;
        path = [ cfg.package ] ++ (with pkgs; [ brotli coreutils ffmpeg ]);
        preStart = ''
          mkdir -p ${lib.escapeShellArg cfg.archivePath}
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
        script = let
          jobLevelSettingsFile =
            settingsFormat.generate "gallery-dl-job-${name}-settings"
            value.settings;
        in ''
          gallery-dl ${lib.escapeShellArgs cfg.extraArgs} ${
            lib.optionalString (cfg.settings != null)
            "--config ${settingsFormatFile}"
          } ${lib.escapeShellArgs value.extraArgs} ${
            lib.optionalString (value.settings != null)
            "--config ${jobLevelSettingsFile}"
          } --destination ${lib.escapeShellArg cfg.archivePath} ${
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
      }) cfg.jobs;
  };
}
