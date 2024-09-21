# The database service of choice. Most services can use this so far
# (thankfully).
{ config, lib, pkgs, ... }:

let
  hostCfg = config.hosts.plover;
  cfg = hostCfg.services.database;

  postgresqlDomain = "postgres.${config.networking.domain}";
in
{
  options.hosts.plover.services.database.enable =
    lib.mkEnableOption "preferred service SQL database";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      state.ports.postgresql.value = 5432;

      services.postgresql = {
        enable = true;
        package = pkgs.postgresql_16;
        enableTCPIP = true;

        settings =
          let
            credsDir = path: "/run/credentials/postgresql.service/${path}";
          in
          {
            port = config.state.ports.postgresql.value;

            # Still doing the secure schema usage pattern.
            search_path = ''"$user"'';

            ssl_cert_file = credsDir "cert.pem";
            ssl_key_file = credsDir "key.pem";
            ssl_ca_file = credsDir "fullchain.pem";
          };
      };

      # With a database comes a dumping.
      services.postgresqlBackup = {
        enable = true;
        compression = "zstd";
        compressionLevel = 11;

        # Start at every 3 days starting from the first day of the month.
        startAt = "*-*-1/3";
      };

      # Setting this up for TLS.
      systemd.services.postgresql = {
        requires = [ "acme-finished-${postgresqlDomain}.target" ];
        serviceConfig.LoadCredential =
          let
            certDirectory = config.security.acme.certs."${postgresqlDomain}".directory;
            certCredentialPath = path: "${path}:${certDirectory}/${path}";
          in
          [
            (certCredentialPath "cert.pem")
            (certCredentialPath "key.pem")
            (certCredentialPath "fullchain.pem")
          ];
      };

      security.acme.certs."${postgresqlDomain}".postRun = ''
        systemctl restart postgresql.service
      '';
    }

    (lib.mkIf hostCfg.services.backup.enable {
      # Add the dumps to be backed up.
      services.borgbackup.jobs.services-backup.paths = [ config.services.postgresqlBackup.location ];
    })
  ]);
}
