{ config, lib, pkgs, ... }:

let
  cfg = config.services.archivebox;
  jobUnitName = name: "archivebox-job-${name}";
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
          Additional arguments for adding links (i.e., {command}`archivebox add
          $LINK`) from {option}`links`.
        '';
        default = [ ];
        example = lib.literalExpression ''
          [ "--depth" "1" ]
        '';
      };

      startAt = lib.mkOption {
        type = with lib.types; str;
        description = ''
          Indicates how frequent the scheduled archiving will occur. Should be
          a valid string format as described from {manpage}`systemd.time(5)`.
        '';
        default = "daily";
        defaultText = "daily";
        example = "*-*-01/2";
      };
    };
  };
in
{
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
            extraArgs = [ "--depth" "1" ];
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

  config =
    let
      pkgSet = [ pkgs.archivebox ] ++ (lib.optionals cfg.withDependencies
        (with pkgs; [ chromium nodejs_latest wget curl youtube-dl ]));
    in
    lib.mkIf cfg.enable {
      assertions = [
        (lib.hm.assertions.assertPlatform "services.archivebox" pkgs
          lib.platforms.linux)
      ];

      home.packages = pkgSet;

      systemd.user.services = lib.mkMerge [
        (lib.mapAttrs'
          (name: value:
            lib.nameValuePair (jobUnitName name) {
              Unit = {
                Description =
                  "Archivebox archive group '${name}' for ${cfg.archivePath}";
                After = [ "network-online.target" ];
                Documentation = [ "https://docs.archivebox.io/" ];
              };

              Service =
                let
                  scriptName = "archivebox-job-${config.home.username}-${name}";
                  script = pkgs.writeShellApplication {
                    name = scriptName;
                    runtimeInputs = with pkgs;
                      [ ripgrep coreutils ] ++ pkgSet
                      ++ [ config.programs.git.package ];
                    text = ''
                      echo "${lib.concatStringsSep "\n" value.links}" \
                        | archivebox add ${lib.concatStringsSep " " value.extraArgs}
                    '';
                  };
                in
                {
                  ExecStart = "${script}/bin/${scriptName}";
                  WorkingDirectory = cfg.archivePath;
                };
            })
          cfg.jobs)

        (lib.mkIf cfg.webserver.enable {
          archivebox-server = {
            Unit = {
              Description = "Archivebox server for ${cfg.archivePath}";
              After = [ "network-online.target" ];
              Wants = [ "network-online.target" ];
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

      systemd.user.timers = lib.mapAttrs'
        (name: value:
          lib.nameValuePair (jobUnitName name) {
            Unit = {
              Description = "Archivebox additions for ${cfg.archivePath}";
              After = [ "network-online.target" ];
              Wants = [ "network-online.target" ];
              Documentation = [ "https://docs.archivebox.io/" ];
            };

            Timer = {
              Persistent = true;
              OnCalendar = value.startAt;
              RandomizedDelaySec = 120;
            };

            Install.WantedBy = [ "timers.target" ];
          })
        cfg.jobs;
    };
}
