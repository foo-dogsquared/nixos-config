{ config, lib, pkgs, foodogsquaredLib, ... }:

let
  hostCfg = config.hosts.plover;
  cfg = hostCfg.services.backup;

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
    environment.BORG_RSH = "ssh -i ${config.sops.secrets."ssh-key".path}";
  };
in
{
  options.hosts.plover.services.backup.enable =
    lib.mkEnableOption "backup service";

  config = lib.mkIf cfg.enable {
    sops.secrets = foodogsquaredLib.sops-nix.getSecrets ../../secrets/secrets.yaml {
      "borg/repos/services/password" = { };
    };

    services.borgbackup.jobs = {
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
       IdentityFile ${config.sops.secrets."ssh-key".path}
    '';
  };
}
