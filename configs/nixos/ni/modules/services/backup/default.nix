# It's a setup for my backup.
{ config, lib, pkgs, ... }:

let
  hostCfg = config.hosts.ni;
  cfg = hostCfg.services.backup;

  borgJobCommonSetting = { patterns ? [ ], passCommand }: {
    compression = "zstd,12";
    dateFormat = "+%F-%H-%M-%S-%z";
    doInit = false;
    encryption = {
      inherit passCommand;
      mode = "repokey-blake2";
    };
    extraCreateArgs = lib.concatStringsSep " "
      (builtins.map (patternFile: "--patterns-from ${patternFile}") patterns);
    extraInitArgs = "--make-parent-dirs";

    # We're emptying them since we're specifying them all through the patterns file.
    paths = [ ];

    persistentTimer = true;
    preHook = ''
      extraCreateArgs="$extraCreateArgs --exclude-if-present .nobackup"
      extraCreateArgs="$extraCreateArgs --stats"
    '';
    prune = {
      keep = {
        within = "1d";
        hourly = 8;
        daily = 30;
        weekly = 4;
        monthly = 6;
        yearly = 3;
      };
    };
  };

  hetzner-boxes-user = "u332477";
  hetzner-boxes-server = "${hetzner-boxes-user}.your-storagebox.de";

  pathPrefix = "borg-backup";
in
{
  options.hosts.ni.services.backup.enable =
    lib.mkEnableOption "backup setup with BorgBackup";

  config = lib.mkIf cfg.enable {
    sops.secrets = lib.private.getSecrets
      ./secrets.yaml
      (lib.private.attachSopsPathPrefix pathPrefix {
        "patterns/home" = { };
        "patterns/etc" = { };
        "patterns/keys" = { };
        "patterns/remote-backup" = { };
        "repos/archive/password" = { };
        "repos/external-drive/password" = { };
        "repos/hetzner-box/password" = { };
        "ssh-key" = { };
      });

    suites.filesystem.setups = {
      archive.enable = true;
      external-hdd.enable = true;
    };

    services.borgbackup.jobs = {
      local-archive = borgJobCommonSetting
        {
          patterns = with config.sops; [
            secrets."${pathPrefix}/patterns/home".path
            secrets."${pathPrefix}/patterns/etc".path
            secrets."${pathPrefix}/patterns/keys".path
          ];
          passCommand = "cat ${config.sops.secrets."${pathPrefix}/repos/archive/password".path}";
        } // {
        removableDevice = true;
        repo = "/mnt/archives/backups";
        startAt = "04:30";
      };

      local-external-drive = borgJobCommonSetting
        {
          patterns = with config.sops; [
            secrets."${pathPrefix}/patterns/home".path
            secrets."${pathPrefix}/patterns/etc".path
            secrets."${pathPrefix}/patterns/keys".path
          ];
          passCommand = "cat ${config.sops.secrets."${pathPrefix}/repos/external-drive/password".path}";
        } // {
        removableDevice = true;
        repo = "/mnt/external-storage/backups";
        startAt = "04:30";
      };

      remote-backup-hetzner-box = borgJobCommonSetting
        {
          patterns = with config.sops; [
            secrets."${pathPrefix}/patterns/remote-backup".path
          ];
          passCommand = "cat ${config.sops.secrets."${pathPrefix}/repos/hetzner-box/password".path}";
        } // {
        doInit = true;
        repo = "ssh://${hetzner-boxes-user}@${hetzner-boxes-server}:23/./borg/desktop/ni";
        startAt = "04:30";
        environment.BORG_RSH = "ssh -i ${config.sops.secrets."${pathPrefix}/ssh-key".path}";
      };
    };

    programs.ssh.extraConfig = ''
      Host ${hetzner-boxes-server}
        IdentityFile ${config.sops.secrets."${pathPrefix}/ssh-key".path}
    '';

    services.btrfs.autoScrub = {
      enable = true;
      fileSystems = [
        "/mnt/archives"
      ];
    };
  };
}
