{ config, options, lib, pkgs, ... }:

let
  cfg = config.services.yt-dlp;

  jobType = { name, config, options, ... }: {
    options = {
      urls = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
        description = ''
          A list of URLs to be downloaded to <command>yt-dlp</command>. Please
          see the list of extractors with <option>--list-extractors</option>.
        '';
        example = lib.literalExpression ''
          [
            "https://www.youtube.com/c/ronillust"
            "https://www.youtube.com/c/Jazza"
          ]
        '';
      };

      startAt = lib.mkOption {
        type = with lib.types; str;
        description = ''
          Indicates how frequent the download will occur. The given schedule should follow the format as described from
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
        description =
          "Job-specific extra arguments to be passed to the <command>yt-dlp</command>.";
        default = [ ];
        example = lib.literalExpression ''
          [
            "--date 'today'"
          ]
        '';
      };
    };
  };
in {
  options.services.yt-dlp = {
    enable = lib.mkEnableOption "archiving service with yt-dlp";

    package = lib.mkOption {
      type = lib.types.package;
      description =
        "The derivation that contains <command>yt-dlp</command> binary.";
      default = pkgs.yt-dlp;
      defaultText = lib.literalExpression "pkgs.yt-dlp";
      example = lib.literalExpression
        "pkgs.yt-dlp.override { phantomjsSupport = true; }";
    };

    archivePath = lib.mkOption {
      type = lib.types.str;
      description = ''
        The location of the archive to be downloaded. Take note it is assumed
        to be created at the time of running the service. Must be an absolute
        path.
      '';
      default = "${
          lib.replaceStrings [ "$HOME" ] [ config.home.homeDirectory ]
          config.xdg.userDirs.videos
        }/yt-dlp-service";
      example = lib.literalExpression
        "\${config.xdg.userDirs.download}/archiving-service/videos";
    };

    extraArgs = lib.mkOption {
      type = with lib.types; listOf str;
      description =
        "List of arguments to be passed to <command>yt-dlp</command>.";
      default = [ "--download-archive '${cfg.archivePath}/download-list" ];
      example = lib.literalExpression ''
        [
          "--download-archive ''${cfg.archivePath}/download-list"
          "--concurrent-fragments 2"
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
              "https://www.youtube.com/c/Jazza"
            ];
            startAt = "weekly";
            extraArgs = [ "--date 'today'" ];
          };

          compsci = {
            urls = [
              "https://www.youtube.com/c/K%C3%A1rolyZsolnai"
              "https://www.youtube.com/c/TheCodingTrain"
            ];
            startAt = "weekly";
          };
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services = lib.mapAttrs' (name: value:
      lib.nameValuePair "yt-dlp-archive-service-${name}" {
        Unit = {
          Description = "yt-dlp archive job for group '${name}'";
          After = "network.target";
          Documentation = "man:yt-dlp(1)";
        };

        Service = {
          ExecStartPre = ''
            ${pkgs.bash}/bin/bash -c "${pkgs.coreutils}/bin/mkdir -p ${
              lib.escapeShellArg cfg.archivePath
            }"
          '';
          ExecStart = let
            scriptName =
              "yt-dlp-archive-service-${config.home.username}-${name}";
            archiveScript = pkgs.writeShellScriptBin scriptName ''
              ${cfg.package}/bin/yt-dlp ${lib.escapeShellArgs cfg.extraArgs} ${
                lib.escapeShellArgs value.extraArgs
              } ${lib.escapeShellArgs value.urls} --paths ${
                lib.escapeShellArg cfg.archivePath
              }
            '';
          in "${archiveScript}/bin/${scriptName}";
        };
      }) cfg.jobs;

    systemd.user.timers = lib.mapAttrs' (name: value:
      lib.nameValuePair "yt-dlp-archive-service-${name}" {
        Unit = {
          Description = "yt-dlp archive job for group '${name}'";
          Documentation = "man:yt-dlp(1)";
        };

        Timer = {
          OnCalendar = value.startAt;
          Persistent = true;
        };

        Install.WantedBy = [ "timers.target" ];
      }) cfg.jobs;
  };
}
