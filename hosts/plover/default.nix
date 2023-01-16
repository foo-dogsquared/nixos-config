{ config, options, lib, pkgs, modulesPath, ... }:

let
  inherit (builtins) toString;

  # The head of the Borgbase hostname.
  hetzner-boxes-user = "u332477";
  hetzner-boxes-server = "${hetzner-boxes-user}.your-storagebox.de";
in
{
  imports = [
    # Since this will be rarely configured, make sure to import the appropriate
    # hardware modules depending on the hosting provider (and even just the
    # server).
    ./modules/hardware/hetzner-cloud-cx21.nix

    # The users for this host.
    (lib.getUser "nixos" "admin")
    (lib.getUser "nixos" "plover")

    # Hardened profile from nixpkgs.
    "${modulesPath}/profiles/hardened.nix"

    ./modules/services/nginx.nix

    # The database of choice which is used by most self-managed services on
    # this server.
    ./modules/services/postgresql.nix

    # The application services for this server. They are modularized since
    # configuring it here will make it too big.
    ./modules/services/atuin.nix
    ./modules/services/gitea.nix
    ./modules/services/keycloak.nix
    ./modules/services/portunus.nix
    ./modules/services/vaultwarden.nix
    ./modules/services/openvpn.nix
  ];

  boot.loader.grub.enable = true;

  networking = {
    nftables.enable = true;
    domain = "foodogsquared.one";
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # Secure Shells.

        80 # HTTP servers.
        433 # HTTPS servers.

        389 # LDAP servers.
        636 # LDAPS servers.
      ];
    };
  };

  # TODO: Put the secrets to the respective service module.
  sops.secrets =
    let
      getKey = key: {
        inherit key;
        sopsFile = ./secrets/secrets.yaml;
      };
      getSecrets = secrets:
        lib.mapAttrs'
          (secret: config:
            lib.nameValuePair
              "plover/${secret}"
              ((getKey secret) // config))
          secrets;

      giteaUserGroup = config.users.users."${config.services.gitea.user}".group;

      # It is hardcoded but as long as the module is stable that way.
      vaultwardenUserGroup = config.users.groups.vaultwarden.name;
      postgresUserGroup = config.users.groups.postgres.name;
    in
    getSecrets {
      "ssh-key" = { };
      "lego/env" = { };
      "gitea/db/password".owner = giteaUserGroup;
      "gitea/smtp/password".owner = giteaUserGroup;
      "vaultwarden/env".owner = vaultwardenUserGroup;
      "borg/repos/host/patterns/keys" = { };
      "borg/repos/host/password" = { };
      "borg/repos/services/password" = { };
      "borg/ssh-key" = { };
      "keycloak/db/password".owner = postgresUserGroup;
      "ldap/users/foodogsquared/password".owner = config.services.portunus.user;
    };

  # All of the keys required to deploy the secrets.
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  profiles.server = {
    enable = true;
    headless.enable = true;
    hardened-config.enable = true;
    cleanup.enable = true;
  };

  # DNS-related settings. We're settling by configuring the ACME setup with a
  # DNS provider.
  security.acme.defaults = {
    dnsProvider = "porkbun";
    credentialsFile = config.sops.secrets."plover/lego/env".path;
  };

  services.openssh.hostKeys = [{
    path = config.sops.secrets."plover/ssh-key".path;
    type = "ed25519";
  }];

  # Of course, what is a server without a backup? A professionally-handled
  # production system. However, we're not professionals so we do have backups.
  services.borgbackup.jobs =
    let
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
        environment.BORG_RSH = "ssh -i ${config.sops.secrets."plover/borg/ssh-key".path}";
      };

      borgRepo = path: "ssh://${hetzner-boxes-user}@${hetzner-boxes-server}:23/./borg/plover/${path}";
    in
    {
      # Backup for host-specific files. They don't change much so it is
      # acceptable for it to be backed up monthly.
      host-backup = jobCommonSettings {
        patternFiles = [
          config.sops.secrets."plover/borg/repos/host/patterns/keys".path
        ];
        repo = borgRepo "host";
        passCommand = "cat ${config.sops.secrets."plover/borg/repos/host/password".path}";
      };

      # Backups for various services.
      services-backup = jobCommonSettings
        {
          paths = [
            # Vaultwarden
            "/var/lib/bitwarden_rs"

            # Gitea
            config.services.gitea.dump.backupDir

            # PostgreSQL database dumps
            config.services.postgresqlBackup.location
          ];
          repo = borgRepo "services";
          passCommand = "cat ${config.sops.secrets."plover/borg/repos/services/password".path}";
        } // { startAt = "weekly"; };
    };

  programs.ssh.extraConfig = ''
    Host ${hetzner-boxes-server}
     IdentityFile ${config.sops.secrets."plover/borg/ssh-key".path}
  '';

  system.stateVersion = "22.11";
}
