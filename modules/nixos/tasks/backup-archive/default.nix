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
      }; in {
      "borg-backup/patterns/home" = getKey "borg-patterns/home";
      "borg-backup/patterns/etc" = getKey "borg-patterns/etc";
      "borg-backup/patterns/keys" = getKey "borg-patterns/keys";
      "borg-backup/patterns/remote-backup" = getKey "borg-patterns/remote-backup";
      "borg-backup/ssh-key" = getKey "ssh-key";
      "borg-backup/password" = getKey "password";
    };

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

    fileSystems."/mnt/archives" = {
      device = "/dev/disk/by-uuid/6ba86a30-5fa4-41d9-8354-fa8af0f57f49";
      fsType = "btrfs";
      noCheck = true;
      options = [
        # These are btrfs-specific mount options which can found in btrfs.5
        # manual page.
        "subvol=@"
        "noatime"
        "compress=zstd:9"
        "space_cache=v2"

        # General mount options from mount.5 manual page.
        "noauto"
        "nofail"
        "user"

        # See systemd.mount.5 and systemd.automount.5 manual page for more
        # details.
        "x-systemd.automount"
        "x-systemd.idle-timeout=2"
        "x-systemd.device-timeout=2"
      ];
    };

    services.borgbackup.jobs = {
      local-archive = borgJobCommonSetting {
        patterns = with config.sops; [
          secrets."borg-backup/patterns/home".path
          secrets."borg-backup/patterns/etc".path
          secrets."borg-backup/patterns/keys".path
        ];
      } // {
        doInit = false;
        removableDevice = true;
        repo = "/mnt/archives/backups";
        startAt = "daily";
      };

      local-external-drive = borgJobCommonSetting {
        patterns = with config.sops; [
          secrets."borg-backup/patterns/home".path
          secrets."borg-backup/patterns/etc".path
          secrets."borg-backup/patterns/keys".path
        ];
      } // {
        doInit = false;
        removableDevice = true;
        repo = "/mnt/external-storage/backups";
        startAt = "daily";
      };

      remote-borgbase = borgJobCommonSetting {
        patterns = with config.sops; [
          secrets."borg-backup/patterns/remote-backup".path
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
