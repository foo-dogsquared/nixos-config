{ config, lib, pkgs, foodogsquaredLib, ... }:

let
  hostCfg = config.users.foo-dogsquared;
  cfg = hostCfg.services.archivebox;

  inherit (config.home) homeDirectory;
  port = builtins.toString config.state.ports.archivebox.value;
  url = "localhost:${port}";
  archiveboxDir = "${config.xdg.userDirs.documents}/ArchiveBox";

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
  options.users.foo-dogsquared.services.archivebox = {
    enable = lib.mkEnableOption "ArchiveBox web UI server (through Podman)";

    jobs = lib.mkOption {
      type = with lib.types; attrsOf (submodule jobType);
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
  };

  config = lib.mkIf cfg.enable {
    state.ports = {
      archivebox.value = 8932;
      sonic.value = 9141;
    };

    home.packages = [
      (pkgs.writeShellScriptBin "archivebox" ''
        podman run --interactive --tty --volume ${archiveboxDir}:/data docker.io/archivebox/archivebox:latest
      '')
    ];

    sops.secrets = foodogsquaredLib.sops-nix.getSecrets ./secrets.yaml {
      "archivebox/env" = { };
      "sonic/env" = { };
    };

    services.podman.containers = lib.mkMerge [
      (lib.mapAttrs' (name: value: lib.nameValuePair (jobUnitName name) {
        image = "docker.io/archivebox/archivebox:latest";
        description = "ArchiveBox job '${name}'";
        volumes = [ "${archiveboxDir}:/data" ];
        autoUpdate = "registry";
        exec = ''echo "${lib.concatStringsSep "\n" value.links}" | archivebox add ${lib.concatStringsSep " " value.extraArgs}'';
        environmentFile = config.services.podman.containers.archivebox-webui.environmentFile;
        environment = config.services.podman.containers.archivebox-webui.environment;
      }) cfg.jobs)

      {
        archivebox-webui = {
          image = "docker.io/archivebox/archivebox:latest";
          description = "ArchiveBox web server";
          ports = [ "${port}:${port}" ];
          volumes = [
            "${archiveboxDir}:/data"
          ];
          autoUpdate = "registry";
          exec = "archivebox server ${url}";
          environmentFile = [ "${config.sops.secrets."archivebox/env".path}" ];
          environment = {
            SEARCH_BACKEND_ENGINE = "sonic";
            SEARCH_BACKEND_HOST_NAME = "sonic";
            PUBLIC_SNAPSHOTS = "True";
            PUBLIC_INDEX = "True";
            PUBLIC_ADD_VIEW = "False";

            SAVE_ARCHIVE_DOT_ORG = "False";
            SAVE_GIT = "False";
          };
        };
      }

      {
        archivebox-sonic-search = {
          image = "docker.io/archivebox/sonic:latest";
          description = "Sonic search instance for ArchiveBox";
          ports = let
            port = builtins.toString config.state.ports.sonic.value;
          in [ "${port}:${port}" ];
          environmentFile = [ "${config.sops.secrets."sonic/env".path}" ];
          volumes = [
            "${config.xdg.userDirs.documents}/ArchiveBox/Sonic:/var/lib/sonic/store"
            "${./config/sonic/sonic.cfg}:/etc/sonic.cfg:ro"
          ];
          extraConfig.Unit.After = [ "podman-archivebox-webui.service" ];
        };
      }
    ];

    users.foo-dogsquared.programs.custom-homepage.sections.services.links = lib.singleton {
      url = "${url}/public";
      text = "Link archive";
    };
  };
}
