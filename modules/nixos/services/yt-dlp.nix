{ config, lib, options, pkgs, ... }:

let
  cfg = config.services.yt-dlp;

  jobUnitName = name: "yt-dlp-archive-service-${name}";

  metadataType = { lib, ... }: {
    options = {
      path = lib.mkOption {
        type = with lib.types; nullOr path;
        description = ''
          Associated path of the metadata to be downloaded. This will be passed to
          the appropriate `--paths` option of yt-dlp.
        '';
        default = null;
        example = "/var/yt-dlp/thumbnails";
      };

      output = lib.mkOption {
        type = with lib.types; nullOr str;
        description = ''
          Associated output name for the metadata. This is passed to the
          appropriate `--output` option of yt-dlp.
        '';
        default = null;
        example = "%(title)s.%(ext)s";
      };
    };
  };

  jobType = { name, config, ... }: {
    options = {
      urls = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
        description = ''
          A list of URLs to be downloaded to {command}`yt-dlp`. Please
          see the list of extractors with `--list-extractors`.
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
          Indicates how frequent the download will occur. The given schedule
          should follow the format as described from
          {manpage}`systemd.time(5)`.
        '';
        default = "daily";
        example = "*-*-3/4";
      };

      extraArgs = options.services.yt-dlp.extraArgs;

      downloadPath = options.services.yt-dlp.downloadPath // {
        default = cfg.downloadPath;
        description = "Job-specific download path of the service.";
      };

      metadata = options.services.yt-dlp.metadata // {
        default = cfg.metadata;
        description = ''
          Per-job set of metadata with their associated options.
        '';
      };
    };

    config.extraArgs =
      let
        mkPathArg = n: v:
          lib.optionals (v.output != null) [ "--output" "${n}:${v.output}" ]
          ++ lib.optionals (v.path != null) [ "--paths" "${n}:${v.path}" ];
      in
        cfg.extraArgs
        ++ (lib.lists.flatten (lib.mapAttrsToList mkPathArg config.metadata))
        ++ [ "--paths" config.downloadPath ];
  };
in
{
  options.services.yt-dlp = {
    enable = lib.mkEnableOption "archiving service with yt-dlp";

    package = lib.mkOption {
      type = lib.types.package;
      description =
        "The derivation that contains {command}`yt-dlp` binary.";
      default = pkgs.yt-dlp;
      defaultText = lib.literalExpression "pkgs.yt-dlp";
      example = lib.literalExpression
        "pkgs.yt-dlp.override { phantomjsSupport = true; }";
    };

    downloadPath = lib.mkOption {
      type = lib.types.path;
      description = "Download path of the service to be given per job (unless overridden).";
      default = "/var/yt-dlp";
      example = "/srv/Videos";
    };

    metadata = lib.mkOption {
      type = with lib.types; attrsOf (submodule metadataType);
      description = ''
        Global set of metadata with their appropriate options to be set.
      '';
      default = { };
      example = {
        thumbnail = {
          path = "/var/yt-dlp/thumbnails";
          output = "%(uploader,artist,creator,Unknown)s/%(title)s.%(ext)s";
        };
        infojson.path = "/var/yt-dlp/infojson";
      };
    };

    extraArgs = lib.mkOption {
      type = with lib.types; listOf str;
      description =
        "Global list of arguments to be passed to each yt-dlp job.";
      default = [ ];
      example = lib.literalExpression ''
        [
          "--verbose"
          "--concurrent-fragments" "2"
          "--retries" "20"
          "--download-archive" "videos"
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
            extraArgs = [ "--date" "today" ];
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
    systemd.services = lib.mapAttrs'
      (name: job:
        lib.nameValuePair (jobUnitName name) {
          inherit (job) startAt;
          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];
          description = "yt-dlp archive job for group '${name}'";
          documentation = [ "man:yt-dlp(1)" ];
          enable = true;
          script = ''
            ${lib.getExe' cfg.package "yt-dlp"} \
              ${lib.escapeShellArgs job.extraArgs} \
              ${lib.escapeShellArgs job.urls}
          '';
          serviceConfig = {
            ReadWritePaths =
              [ job.downloadPath ]
              ++ lib.mapAttrsToList (n: v: lib.optionals (v.path != null) v.path) job.metadata;

            LockPersonality = true;
            NoNewPrivileges = true;
            PrivateDevices = true;
            PrivateTmp = true;
            PrivateUsers = true;
            PrivateMounts = true;
            ProtectClock = true;
            ProtectControlGroups = true;
            ProtectHome = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            ProtectSystem = "full";
            RemoveIPC = true;
            StandardOutput = "journal";
            StandardError = "journal";
            SystemCallFilter = "@system-service";
            SystemCallErrorNumber = "EPERM";

            CapabilityBoundingSet = lib.mkDefault [ ];
            AmbientCapabilities = lib.mkDefault [ ];
            RestrictAddressFamilies = [
              "AF_LOCAL"
              "AF_INET"
              "AF_INET6"
            ];
            RestrictNamespaces = true;
            RestrictSUIDGUID = true;
            MemoryDenyWriteExecute = true;
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
