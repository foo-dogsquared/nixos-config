{ config, options, lib, pkgs, ... }:

let
  cfg = config.services.archivebox;
  jobType = { name, options, ... }: {
    options = {
      links = lib.mkOption {
        type = with lib.types; listOf str;
        description = "List of links to archive.";
        example = lib.literalExpression ''
          [
            "https://guix.gnu.org/feeds/blog.atom"
            "https://nixos.org/blog/announcements-rss.xml"
          ]
        '';
      };

      extraArgs = lib.mkOption {
        type = with lib.types; listOf str;
        description = ''
          Additional arguments for adding links (i.e., <literal>archivebox add
          $LINK</literal>) from <option>links</option>.
        '';
        default = [ ];
        example = lib.literalExpression ''
          [ "--depth 1" ]
        '';
      };

      startAt = lib.mkOption {
        type = with lib.types; str;
        description = ''
          Indicates how frequent the scheduled archiving will occur.
          Should be a valid string format as described from systemd.time(5).
        '';
        default = "weekly";
        defaultText = "weekly";
        example = "*-*-01/2";
      };
    };
  };
in {
  options.services.archivebox = {
    enable = lib.mkEnableOption "Archivebox service";

    archivePath = lib.mkOption {
      type = with lib.types; either path str;
      description = ''
        The path of the Archivebox archive. Must be an absolute path.
      '';
      example = "/var/archives/archivebox-service";
    };

    jobs = lib.mkOption {
      type = with lib.types; attrsOf (submodule jobType);
      description = "A map of archiving tasks for the service.";
      default = { };
      defaultText = lib.literalExpression "{}";
      example = lib.literalExpression ''
        {
          illustration = {
            links = [
              "https://www.davidrevoy.com/"
              "https://www.youtube.com/c/ronillust"
            ];
            startAt = "weekly";
          };

          research = {
            links = [
              "https://arxiv.org/rss/cs"
              "https://distill.pub/"
            ];
            extraArgs = [ "--depth 1" ];
            startAt = "daily";
          };
        }
      '';
    };

    withDependencies =
      lib.mkEnableOption "additional dependencies to be installed";

    webserver = {
      enable = lib.mkEnableOption "web UI for Archivebox";

      port = lib.mkOption {
        type = lib.types.port;
        description = "The port number to be used for the server at localhost.";
        default = 8000;
        example = 8888;
      };
    };
  };

  config = let
    pkgSet = [ pkgs.archivebox ] ++ (lib.optionals cfg.withDependencies
      (with pkgs; [ chromium nodejs_latest wget curl youtube-dl ]));
  in lib.mkIf cfg.enable {
    systemd.services = lib.mkMerge [
      (lib.mapAttrs' (name: value:
        lib.nameValuePair "archivebox-add-${name}" {
          description =
            "Archivebox archive group '${name}' for ${cfg.archivePath}";
          after = [ "network.target" ];
          documentation = [ "https://docs.archivebox.io/" ];
          path = with pkgs;
            [ ripgrep coreutils ] ++ pkgSet ++ [ config.programs.git.package ];
          preStart = ''
            mkdir -p ${lib.escapeShellArg cfg.archivePath}
          '';
          script = ''
            echo "${lib.concatStringsSep "\n" value.links}" \
              | archivebox add ${lib.concatStringsSep " " value.extraArgs}
          '';
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
            WorkingDirectory = cfg.archivePath;
          };
        }) cfg.jobs)

      (lib.mkIf cfg.webserver.enable {
        archivebox-server = {
          description = "Archivebox server for ${cfg.archivePath}";
          after = [ "network.target" ];
          documentation = [ "https://docs.archivebox.io/" ];
          wantedBy = [ "graphical-session.target" ];
          preStart = ''
            mkdir -p ${lib.escapeShellArg cfg.archivePath}
          '';
          serviceConfig = {
            ExecStart = "${pkgs.archivebox}/bin/archivebox server localhost:${
                toString cfg.webserver.port
              }";
            Restart = "on-failure";
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
            WorkingDirectory = cfg.archivePath;
          };
        };
      })
    ];

    systemd.timers = lib.mapAttrs' (name: value:
      lib.nameValuePair "archivebox-add-${name}" {
        description =
          "Archivebox archive group '${name}' for ${cfg.archivePath}";
        after = [ "network.target" ];
        documentation = [ "https://docs.archivebox.io/" ];
        timerConfig = {
          Persistent = true;
          OnCalendar = value.startAt;
          RandomizedDelaySec = 120;
        };
        wantedBy = [ "timers.target" ];
      }) cfg.jobs;
  };
}
