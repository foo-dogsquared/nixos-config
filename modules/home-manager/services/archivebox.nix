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

      extraOptions = lib.mkOption {
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
        default = "daily";
        defaultText = "daily";
        example = "*-*-01/2";
      };
    };
  };
in {
  options.services.archivebox = {
    enable = lib.mkEnableOption "Archivebox service";

    archivePath = lib.mkOption {
      type = with lib.types; either path str;
      description = "The path of the Archivebox archive.";
      example = "\${config.xdg.dataHome}/archivebox";
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
            extraOptions = [ "--depth 1" ];
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

  config = lib.mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "services.archivebox" pkgs
        lib.platforms.linux)
    ];

    home.packages = [ pkgs.archivebox ] ++ (lib.optionals cfg.withDependencies
      (with pkgs; [ chromium nodejs_latest wget curl youtube-dl ]));

    systemd.user.services = lib.mkMerge [
      (lib.mapAttrs' (name: value:
        lib.nameValuePair "archivebox-add-${name}" {
          Unit = {
            Description = "Archivebox archive group '${name}' for ${cfg.archivePath}";
            After = "network.target";
            Documentation = [ "https://docs.archivebox.io/" ];
          };

          Install.WantedBy = [ "default.target" ];

          Service = let
            scriptName = "archivebox-job-${config.home.username}-${name}";
            script = pkgs.writeShellApplication  {
              name = scriptName;
              runtimeInputs = with pkgs; [ coreutils archivebox ];
              text = ''
                echo "${lib.concatStringsSep "\n" value.links}" \
                  | archivebox add ${lib.concatStringsSep " " value.extraOptions}
              '';
            };
          in {
            ExecStart = "${script}/bin/${scriptName}";
            WorkingDirectory = cfg.archivePath;
          };
        }) cfg.jobs)

      (lib.mkIf cfg.webserver.enable {
        archivebox-server = {
          Unit = {
            Description = "Archivebox server for ${cfg.archivePath}";
            After = "network.target";
            Documentation = [ "https://docs.archivebox.io/" ];
          };

          Install.WantedBy = [ "graphical-session.target" ];

          Service = {
            ExecStart = "${pkgs.archivebox}/bin/archivebox server localhost:${
                toString cfg.webserver.port
              }";
            WorkingDirectory = cfg.archivePath;
            Restart = "on-failure";
          };
        };
      })
    ];

    systemd.user.timers = lib.mapAttrs' (name: value:
      lib.nameValuePair "archivebox-add-${name}" {
        Unit = {
          Description = "Archivebox additions for ${cfg.archivePath}";
          After = "network.target";
          Documentation = [ "https://docs.archivebox.io/" ];
        };

        Timer = {
          Persistent = true;
          OnCalendar = value.startAt;
          RandomizedDelaySec = 120;
        };

        Install.WantedBy = [ "timers.target" ];
      }) cfg.jobs;
  };
}
