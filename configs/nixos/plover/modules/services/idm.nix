{ config, lib, pkgs, ... }:

let
  hostCfg = config.hosts.plover;
  cfg = hostCfg.services.idm;

  authDomain = "auth.${config.networking.domain}";
  port = config.state.ports.kanidm.value;

  certsDir = config.security.acme.certs."${authDomain}".directory;

  backupsDir = "${config.state.paths.dataDir}/kanidm/backups";
in {
  options.hosts.plover.services.idm.enable =
    lib.mkEnableOption "preferred IDM server";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      state.ports.kanidm.value = 9443;
      hosts.plover.services.vouch-proxy.enable = lib.mkDefault true;

      services.kanidm = {
        enableServer = true;
        enablePam = true;

        serverSettings = {
          domain = authDomain;
          origin = "https://${authDomain}";
          bindaddress = "127.0.0.1:${builtins.toString port}";
          ldapbindaddress = "127.0.0.1:3636";
          role = "WriteReplica";
          trust_x_forward_for = true;

          tls_chain = "${certsDir}/fullchain.pem";
          tls_key = "${certsDir}/key.pem";

          online_backup = {
            path = backupsDir;
            schedule = "0 0 * * *";
          };
        };

        clientSettings = {
          uri = "https://${authDomain}";
          verify_hostnames = true;
          verify_ca = true;
        };

        unixSettings = {
          use_etc_skel = false;
          pam_allowed_login_groups = [ "kanidm" ];
        };
      };

      # Additional SSH server hardening.
      services.openssh.settings = {
        PermitEmptyPasswords = "no";
        GSSAPIAuthentication = "no";
        KerberosAuthentication = "no";

        # Integrating kanidm-unixd.
        UsePAM = true;
        PubkeyAuthentication = true;
        AuthorizedKeysCommand = "${
            lib.getExe' config.services.kanidm.package
            "kanidm_ssh_authorizedkeys"
          } %u";
        AuthorizedKeysCommandUser = "nobody";
      };

      # The kanidm Nix module already sets the certificates directory to be
      # read-only with systemd so no need for it though we may need to set the
      # backups directory.
      systemd.services.kanidm = {
        preStart = lib.mkBefore ''
          mkdir -p "${backupsDir}"
        '';
        serviceConfig = {
          SupplementaryGroups =
            [ config.security.acme.certs."${authDomain}".group ];
        };
      };
    }

    (lib.mkIf hostCfg.services.reverse-proxy.enable {
      services.nginx.virtualHosts."${authDomain}" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        kTLS = true;
        locations."/".proxyPass = "https://kanidm";
      };

      services.nginx.upstreams."kanidm" = {
        extraConfig = ''
          zone services;
        '';
        servers = { "localhost:${builtins.toString port}" = { }; };
      };
    })

    (lib.mkIf hostCfg.services.backup.enable {
      # Add the following to be backed up.
      services.borgbackup.jobs.services-backup.paths = [ backupsDir ];
    })
  ]);
}
