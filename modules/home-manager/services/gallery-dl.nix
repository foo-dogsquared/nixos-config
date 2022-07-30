{ config, options, lib, pkgs, ... }:

let
  cfg = config.services.gallery-dl;

  settingsFormat = pkgs.formats.json { };
  settingsFormatFile =
    settingsFormat.generate "gallery-dl-service-config-${config.home.username}"
    cfg.settings;

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

      persistent = lib.mkOption {
        type = lib.types.bool;
        description = ''
          Indicates whether job is persistent, starting the service despite the
          timer missed. Defaults to <literal>true</literal> assuming it is used
          on the desktop.
        '';
        default = true;
        defaultText = "true";
        example = "false";
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
            "--date" "today-1week" # get only videos from a week ago
            "--output" "%(uploader)s/%(title)s.%(ext)s" # download them in the respective directory
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
        to be created at the time of running the service. Must be an absolute
        path.
      '';
      default = "${config.xdg.userDirs.pictures}/gallery-dl-service";
      example = lib.literalExpression
        "\${config.xdg.userDirs.download}/archiving-service/photos";
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
    home.packages = [ cfg.package ];

    systemd.user.services = lib.mapAttrs' (name: value:
      lib.nameValuePair "gallery-dl-archive-service-${name}" {
        Unit = {
          Description = "gallery-dl archive job for group '${name}'";
          After = [ "default.target" ];
          Documentation = "man:gallery-dl(1)";
        };

        Service.ExecStart = let
          scriptName = "gallery-dl-service-${config.home.username}-${name}";
          jobSpecificSettingsFile =
            settingsFormat.generate "gallery-dl-service-job-${name}-settings"
            value.settings;
          archiveScript = pkgs.writeShellScriptBin scriptName ''
            ${cfg.package}/bin/gallery-dl ${
              lib.escapeShellArgs cfg.extraArgs
            } ${
              lib.optionalString (cfg.settings != null)
              "--config ${settingsFormatFile}"
            } ${lib.escapeShellArgs value.extraArgs} ${
              lib.optionalString (value.settings != null)
              "--config ${jobSpecificSettingsFile}"
            } --destination ${cfg.archivePath} ${lib.escapeShellArgs value.urls}
          '';
        in "${archiveScript}/bin/${scriptName}";
      }) cfg.jobs;

    systemd.user.timers = lib.mapAttrs' (name: value:
      lib.nameValuePair "gallery-dl-archive-service-${name}" {
        Unit = {
          Description = "gallery-dl archive job for group '${name}'";
          Documentation = "man:gallery-dl(1)";
        };

        Timer = {
          OnCalendar = value.startAt;
          Persistent = value.persistent;
          RandomizedDelaySec = "2min";
        };

        Install.WantedBy = [ "timers.target" ];
      }) cfg.jobs;
  };
}
