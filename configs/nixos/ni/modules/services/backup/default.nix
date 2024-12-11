# It's a setup for my backup.
{ config, lib, pkgs, foodogsquaredLib, ... }:

let
  hostCfg = config.hosts.ni;
  cfg = hostCfg.services.backup;

  borgJobCommonSetting = { patterns ? [ ], passCommand, ... }@args:
  let
    args' = lib.attrsets.removeAttrs args [ "patterns" "passCommand" ];
  in
  {
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
    paths = lib.mkForce [ ];

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
  } // args';

  hetzner-boxes-user = "u332477";
  hetzner-boxes-server = "${hetzner-boxes-user}.your-storagebox.de";

  pathPrefix = "borg-backup";
in
{
  options.hosts.ni.services.backup.enable =
    lib.mkEnableOption "backup setup with BorgBackup";

  config = lib.mkIf cfg.enable {
    sops.secrets = foodogsquaredLib.sops-nix.getSecrets
      ./secrets.yaml
      (foodogsquaredLib.sops-nix.attachSopsPathPrefix pathPrefix {
        "patterns/home" = { };
        "patterns/root" = { };
        "patterns/keys" = { };
        "repos/archives/password" = { };
        "repos/external-hdd/password" = { };
        "repos/hetzner-box/password" = { };
        "repos/hetzner-box/ssh-key" = { };
      });

    suites.filesystem.setups = {
      laptop-ssd.enable = true;
    };

    services.borgbackup.jobs = {
      local-external-storage = borgJobCommonSetting {
        patterns = with config.sops; [
          secrets."${pathPrefix}/patterns/root".path
          secrets."${pathPrefix}/patterns/keys".path
        ];
        passCommand = "cat ${config.sops.secrets."${pathPrefix}/repos/external-hdd/password".path}";
        removableDevice = true;
        doInit = true;
        repo = "${config.state.paths.laptop-ssd}/Backups";
      };

      remote-backup-hetzner-box = borgJobCommonSetting {
        patterns = with config.sops; [
          secrets."${pathPrefix}/patterns/home".path
        ];
        passCommand = "cat ${config.sops.secrets."${pathPrefix}/repos/hetzner-box/password".path}";
        doInit = true;
        repo = "ssh://${hetzner-boxes-user}@${hetzner-boxes-server}:23/./borg/desktop/ni";
        startAt = "04:30";
        environment.BORG_RSH = "ssh -i ${config.sops.secrets."${pathPrefix}/repos/hetzner-box/ssh-key".path}";
      };
    };
  };
}
