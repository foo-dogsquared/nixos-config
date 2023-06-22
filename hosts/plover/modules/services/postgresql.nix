# The database service of choice. Most services can use this so far
# (thankfully).
{ config, lib, pkgs, ... }:

let
  postgresqlDomain = "postgres.${config.networking.domain}";
in
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    enableTCPIP = true;

    # Create per-user schema as documented from Usage Patterns. This is to make
    # use of the secure schema usage pattern they encouraged to do.
    #
    # Now, you just have to keep in mind about applications making use of them.
    # Most of them should have the setting to set the schema to be used. If
    # not, then screw them (or just file an issue and politely ask for the
    # feature).
    initialScript =
      let
        # This will be run once anyways so it is acceptable to create users
        # "forcibly".
        perUserSchemas = lib.lists.map
          (user: ''
            CREATE USER ${user.name};
            CREATE SCHEMA AUTHORIZATION ${user.name};
          '')
          config.services.postgresql.ensureUsers;
      in
      pkgs.writeText "plover-initial-postgresql-script" ''
        ${lib.concatStringsSep "\n" perUserSchemas}
      '';

    settings = let
      credsDir = path: "/run/credentials/postgresql.service/${path}";
    in {
      # Still doing the secure schema usage pattern.
      search_path = "\"$user\"";

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
    serviceConfig.LoadCredential = let
      certDirectory = config.security.acme.certs."${postgresqlDomain}".directory;
      certCredentialPath = path: "${path}:${certDirectory}/${path}";
    in
    [
      (certCredentialPath "cert.pem")
      (certCredentialPath "key.pem")
      (certCredentialPath "fullchain.pem")
    ];
  };

  security.acme.certs."${postgresqlDomain}".reloadServices = [
    "postgresql.service"
  ];
}
