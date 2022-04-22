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
        The location of the archive to be downloaded. Must be an absolute path.
      '';
      default = "/archives/yt-dlp-service";
      example = lib.literalExpression "/archiving-service/videos";
    };

    extraArgs = lib.mkOption {
      type = with lib.types; listOf str;
      description =
        "List of arguments to be passed to <command>yt-dlp</command>.";
      default = [ "--download-archive videos" ];
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
    systemd.services = lib.mapAttrs' (name: value:
      lib.nameValuePair "yt-dlp-archive-service-${name}" {
        after = [ "network.target" ];
        description = "yt-dlp archive job for group '${name}'";
        documentation = [ "man:yt-dlp(1)" ];
        enable = true;
        path = [ cfg.package pkgs.coreutils ];
        preStart = ''
          mkdir -p ${lib.escapeShellArg cfg.archivePath}
        '';
        script = ''
          yt-dlp ${lib.concatStringsSep " " cfg.extraArgs} ${
            lib.concatStringsSep " " value.extraArgs
          } ${lib.escapeShellArgs value.urls} --paths ${cfg.archivePath}
        '';
        startAt = value.startAt;
        serviceConfig = {
          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectControlGroups = true;
          ProtectClock = true;
          ProtectKernelModules = true;
          ProtectKernelLogs = true;
        };
      }) cfg.jobs;
  };
}
