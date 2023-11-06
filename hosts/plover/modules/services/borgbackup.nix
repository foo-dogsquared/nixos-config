{ config, lib, pkgs, ... }:

let
  # The head of the Borgbase hostname.
  hetzner-boxes-user = "u332477";
  hetzner-boxes-server = "${hetzner-boxes-user}.your-storagebox.de";
  borgRepo = path: "ssh://${hetzner-boxes-user}@${hetzner-boxes-server}:23/./borg/plover/${path}";

  jobCommonSettings = { patternFiles ? [ ], patterns ? [ ], paths ? [ ], repo, passCommand }: {
    inherit paths repo;
    compression = "zstd,11";
    dateFormat = "+%F-%H-%M-%S-%z";
    doInit = true;
    encryption = {
      inherit passCommand;
      mode = "repokey-blake2";
    };
    extraCreateArgs =
      let
        args = lib.flatten [
          (builtins.map
            (patternFile: "--patterns-from ${lib.escapeShellArg patternFile}")
            patternFiles)
          (builtins.map
            (pattern: "--pattern ${lib.escapeShellArg pattern}")
            patterns)
        ];
      in
      lib.concatStringsSep " " args;
    extraInitArgs = "--make-parent-dirs";
    persistentTimer = true;
    preHook = ''
      extraCreateArgs="$extraCreateArgs --stats"
    '';
    prune.keep = {
      weekly = 4;
      monthly = 12;
      yearly = 6;
    };
    startAt = "monthly";
    environment.BORG_RSH = "ssh -i ${config.sops.secrets."borg/ssh-key".path}";
  };
in
{
  sops.secrets = lib.getSecrets ../../secrets/secrets.yaml {
    "borg/repos/host/patterns/keys" = { };
    "borg/repos/host/password" = { };
    "borg/repos/services/password" = { };
    "borg/ssh-key" = { };
  };

  services.borgbackup.jobs = {
    # Backup for host-specific files. They don't change much so it is
    # acceptable for it to be backed up monthly.
    host-backup = jobCommonSettings {
      patternFiles = [
        config.sops.secrets."borg/repos/host/patterns/keys".path
      ];
      repo = borgRepo "host";
      passCommand = "cat ${config.sops.secrets."borg/repos/host/password".path}";
    };

    # Backups for various services.
    services-backup = jobCommonSettings
      {
        paths = [
          # ACME accounts and TLS certificates
          "/var/lib/acme"
        ];
        repo = borgRepo "services";
        passCommand = "cat ${config.sops.secrets."borg/repos/services/password".path}";
      } // { startAt = "daily"; };
  };

  programs.ssh.extraConfig = ''
    Host ${hetzner-boxes-server}
     IdentityFile ${config.sops.secrets."borg/ssh-key".path}
  '';
}
