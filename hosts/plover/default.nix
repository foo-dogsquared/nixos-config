{ config, options, lib, pkgs, modulesPath, ... }:

let
  inherit (builtins) toString;
  inherit (import ./modules/hardware/networks.nix) interfaces;

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

    # The primary DNS server that is completely hidden.
    ./modules/services/bind.nix

    # The reverse proxy of choice.
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
    ./modules/services/wireguard.nix
    ./modules/services/wezterm-mux-server.nix
  ];

  # Automatic format and partitioning.
  disko.devices = import ./disko.nix {
    disks = [ "/dev/sda" ];
  };

  networking = {
    nftables.enable = true;
    domain = "foodogsquared.one";
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # Secure Shells.
      ];
    };
  };

  services.fail2ban = {
    ignoreIP = [
      # VPN clients.
      "${interfaces.wireguard0.IPv4.address}/13"
      "${interfaces.wireguard0.IPv6.address}/64"
    ];

    # We're going to be unforgiving with this one since we only have key
    # authentication and password authentication is disabled anyways.
    jails.sshd.settings = {
      enabled = true;
      maxretry = 1;
    };
  };

  sops.secrets = lib.getSecrets ./secrets/secrets.yaml {
    "ssh-key" = { };
    "lego/env" = { };

    "borg/repos/host/patterns/keys" = { };
    "borg/repos/host/password" = { };
    "borg/repos/services/password" = { };
    "borg/ssh-key" = { };
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
  # self-hosted DNS server.
  security.acme.defaults = {
    email = "admin+acme@foodogsquared.one";
    dnsProvider = "rfc2136";
    dnsResolver = "1.1.1.1";
    credentialsFile = config.sops.secrets."lego/env".path;
  };

  # Enable generating new DH params.
  security.dhparams.enable = true;

  # !!! The keys should be rotated at an interval here.
  services.openssh.hostKeys = [{
    path = config.sops.secrets."ssh-key".path;
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
        environment.BORG_RSH = "ssh -i ${config.sops.secrets."borg/ssh-key".path}";
      };

      borgRepo = path: "ssh://${hetzner-boxes-user}@${hetzner-boxes-server}:23/./borg/plover/${path}";
    in
    {
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
        } // { startAt = "weekly"; };
    };

  programs.ssh.extraConfig = ''
    Host ${hetzner-boxes-server}
     IdentityFile ${config.sops.secrets."borg/ssh-key".path}
  '';

  system.stateVersion = "23.05";
}
