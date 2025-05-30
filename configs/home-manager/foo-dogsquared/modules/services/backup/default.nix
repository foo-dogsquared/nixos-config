{ config, lib, foodogsquaredLib, pkgs, ... }@attrs:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.services.backup;

  pathPrefix = "borg-backup";
  getPath = path: config.sops.secrets."${pathPrefix}/${path}".path;
  isFilesystemSet = setupName:
    attrs.nixosConfig.suites.filesystem.setups.${setupName}.enable or false;

  hetznerBoxesUser = "u332477";
  hetznerBoxesServer = "${hetznerBoxesUser}.your-storagebox.de";

  borgmaticCommonConfig = module:
    lib.mkMerge [
      module

      {
        archive_name_format =
          lib.mkDefault "{fqdn}-home-manager-personal-{now}";
        patterns = lib.mkBefore [
          "R ${config.home.homeDirectory}"
          "! ${config.xdg.dataHome}"
          "! ${config.xdg.cacheHome}"
          "- ${config.xdg.configHome}"
          "- ${config.xdg.userDirs.download}"
          "+ ${config.xdg.userDirs.extraConfig.XDG_PROJECTS_DIR}"
          "+ ${config.xdg.userDirs.documents}"
          "+ ${config.xdg.userDirs.music}"
          "+ ${config.xdg.userDirs.pictures}"
          "+ ${config.xdg.userDirs.templates}"
          "+ ${config.xdg.userDirs.videos}"
          "+ ${config.home.homeDirectory}/.thunderbird"
          "+ ${config.xdg.dataHome}/gopass"
          "+ ${config.xdg.configHome}/age"
          "+ ${config.xdg.configHome}/sops"
        ];
        exclude_if_present = [ ".nobackup" ".exclude.bak" ];
        exclude_patterns =
          [ "node_modules/" "*.pyc" "result*/" "*/.vim*.tmp" "target/" ];

        store_config_files = true;

        # Most of these retention settings are meant to have overlaps in the
        # periodic backups.
        keep_hourly = 48;
        keep_daily = 14;
        keep_weekly = 8;
        keep_monthly = 12;
        keep_yearly = 4;

        check_last = 4;
      }
    ];

  checkRemovableMountScript =
    pkgs.writeShellScript "check-for-removable-storage" ''
      { findmnt "$(dirname "$1")" > /dev/null && [ -d "$1" ]; } || exit 75
    '';
in {
  options.users.foo-dogsquared.services.backup.enable =
    lib.mkEnableOption "preferred backup service";

  config = lib.mkIf cfg.enable {
    sops.secrets = foodogsquaredLib.sops-nix.getSecrets ./secrets.yaml
      (foodogsquaredLib.sops-nix.attachSopsPathPrefix pathPrefix {
        "repos/remote-hetzner-boxes-personal/password" = { };
        "repos/local-external-hdd-personal/password" = { };
        "repos/local-archive-personal/password" = { };
      });

    programs.borgmatic.enable = true;
    programs.borgmatic.backups = lib.mkMerge [
      {
        remote-hetzner-boxes-personal = {
          initService.enable = true;
          initService.startAt = "06:30";
          settings = borgmaticCommonConfig {
            encryption_passcommand =
              "cat ${getPath "repos/remote-hetzner-boxes-personal/password"}";
            repositories = lib.singleton {
              path =
                "ssh://${hetznerBoxesUser}@${hetznerBoxesServer}:23/./borg/users/${config.home.username}";
              label = "remote-hetzner-boxes";
            };
            extra_borg_options = {
              init = builtins.toString [
                "--make-parent-dirs"
                "--encryption"
                "repokey-blake2"
              ];
            };
          };
        };
      }

      (lib.mkIf (isFilesystemSet "external-hdd") {
        local-external-hdd-personal = {
          initService.enable = true;
          initService.startAt = "04:30";
          settings = let
            removablePath =
              "${attrs.nixosConfig.state.paths.external-hdd}/Backups";
          in borgmaticCommonConfig {
            encryption_passcommand =
              "cat ${getPath "repos/local-external-hdd-personal/password"}";
            repositories = lib.singleton {
              path = removablePath;
              label = "local-external-hdd";
            };
            relocated_repo_access_is_ok = true;
            before_backup =
              lib.singleton "${checkRemovableMountScript} ${removablePath}";
          };
        };
      })

      {
        local-archive-personal = {
          initService.enable = true;
          initService.startAt = "04:30";
          settings = borgmaticCommonConfig {
            encryption_passcommand =
              "cat ${getPath "repos/local-archive-personal/password"}";
            repositories = lib.singleton {
              path =
                "\${BORG_PERSONAL_FDS_PATH:-${attrs.nixosConfig.state.paths.laptop-ssd}/Backups/foodogsquared}";
              label = "local-archive";
            };
          };
        };
      }
    ];

    # My game backups.
    services.ludusavi = {
      enable = true;
      startAt = "daily";

      settings = let backup_path = "${config.xdg.cacheHome}/ludusavi/backups";
      in {
        manifest.enable = true;
        roots = [
          {
            path = "${config.home.homeDirectory}/.steam";
            store = "steam";
          }
          {
            path = "${config.xdg.dataHome}/lutris";
            store = "lutris";
          }
        ];
        backup.path = backup_path;
        restore.path = backup_path;
        release.check = false;
      };
    };
  };
}
