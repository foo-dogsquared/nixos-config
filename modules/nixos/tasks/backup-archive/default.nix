# It's a setup for my backup.
{ config, options, lib, pkgs, ... }:

let
  cfg = config.tasks.backup-archive;

  borgJobCommonSetting = { patterns ? [ ] }: {
    compression = "zstd,9";
    dateFormat = "+%F-%H-%M-%S-%z";
    doInit = true;
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat ${config.sops.secrets."borg-backup/password".path}";
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

in {
  options.tasks.backup-archive.enable =
    lib.mkEnableOption "backup setup with BorgBackup";

  config = lib.mkIf cfg.enable {
    sops.secrets = let
      getKey = key: {
        inherit key;
        sopsFile = lib.getSecret "backup-archive.yaml";
        name = "borg-backup/${key}";
      };
      getSecrets = keys:
        lib.listToAttrs (lib.lists.map (key: lib.nameValuePair key (getKey key)) keys);
    in getSecrets [
      "borg-patterns/home"
      "borg-patterns/etc"
      "borg-patterns/keys"
      "borg-patterns/remote-backup"
      "ssh-key"
      "password"
    ];

    profiles.filesystem = {
      archive.enable = true;
      external-hdd.enable = true;
    };

    services.borgbackup.jobs = {
      local-archive = borgJobCommonSetting {
        patterns = with config.sops; [
          secrets."borg-backup/borg-patterns/home".path
          secrets."borg-backup/borg-patterns/etc".path
          secrets."borg-backup/borg-patterns/keys".path
        ];
      } // {
        doInit = false;
        removableDevice = true;
        repo = "/mnt/archives/backups";
        startAt = "daily";
      };

      local-external-drive = borgJobCommonSetting {
        patterns = with config.sops; [
          secrets."borg-backup/borg-patterns/home".path
          secrets."borg-backup/borg-patterns/etc".path
          secrets."borg-backup/borg-patterns/keys".path
        ];
      } // {
        doInit = false;
        removableDevice = true;
        repo = "/mnt/external-storage/backups";
        startAt = "daily";
      };

      remote-borgbase = borgJobCommonSetting {
        patterns = with config.sops; [
          secrets."borg-backup/borg-patterns/remote-backup".path
        ];
      } // {
        repo = "r6o30viv@r6o30viv.repo.borgbase.com:repo";
        startAt = "daily";
        environment.BORG_RSH = "ssh -i ${config.sops.secrets."borg-backup/ssh-key".path}";
      };
    };

    programs.ssh.extraConfig = ''
      Host *.repo.borgbase.com
       IdentityFile ${config.sops.secrets."borg-backup/ssh-key".path}
    '';
  };
}
