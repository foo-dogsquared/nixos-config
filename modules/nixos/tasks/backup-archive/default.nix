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
      passCommand = "cat ${config.age.secrets.borg-password.path}";
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
    age.secrets.borg-password.file = lib.getSecret "archive/password";
    age.secrets.borg-patterns.file = lib.getSecret "archive/borg-patterns";
    age.secrets.borg-patterns-local.file =
      lib.getSecret "archive/borg-patterns-local";
    age.secrets.borg-ssh-key.file = lib.getSecret "archive/borg-ssh-key";

    fileSystems."/mnt/external-storage" = {
      device = "/dev/disk/by-uuid/665A391C5A38EB07";
      fsType = "ntfs";
      noCheck = true;
      options = [
        "nofail"
        "noauto"
        "user"

        # See systemd.mount.5 and systemd.automount.5 manual page for more
        # details.
        "x-systemd.automount"
        "x-systemd.device-timeout=2"
        "x-systemd.idle-timeout=2"
      ];
    };

    services.borgbackup.jobs = {
      local = borgJobCommonSetting {
        patterns = [
          config.age.secrets.borg-patterns-local.path
          config.age.secrets.borg-patterns.path
        ];
      } // {
        repo = "/archives/backups";
        startAt = "04/5:00:00";
      };

      local-archive = borgJobCommonSetting {
        patterns = [
          config.age.secrets.borg-patterns-local.path
          config.age.secrets.borg-patterns.path
        ];
      } // {
        doInit = false;
        removableDevice = true;
        repo = "/mnt/external-storage/backups";
        startAt = "daily";
      };

      remote-borgbase = borgJobCommonSetting {
        patterns = [ config.age.secrets.borg-patterns.path ];
      } // {
        repo = "r6o30viv@r6o30viv.repo.borgbase.com:repo";
        startAt = "daily";
        environment.BORG_RSH = "ssh -i ${config.age.secrets.borg-ssh-key.path}";
      };
    };

    programs.ssh.extraConfig = ''
      Host *.repo.borgbase.com
       IdentityFile ${config.age.secrets.borg-ssh-key.path}
    '';
  };
}
