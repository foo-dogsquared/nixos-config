{ config, options, lib, pkgs, ... }:

let
  inherit (builtins) toString;
  domain = config.networking.domain;
  passwordManagerDomain = "pass.${domain}";

  # This should be set from service module from nixpkgs.
  vaultwardenUser = config.users.users.vaultwarden.name;

  # However, this is set on our own.
  vaultwardenDbName = "vaultwarden";
in
{
  imports = [
    ./hardware-configuration.nix
    (lib.getUser "nixos" "admin")

    (lib.mapHomeManagerUser "plover" {})
    (lib.getUser "nixos" "plover")
  ];

  networking.domain = "foodogsquared.one";

  sops.secrets =
    let
      getKey = key: {
        inherit key;
        sopsFile = ./secrets/secrets.yaml;
      };
      getSecrets = keys:
        lib.listToAttrs (lib.lists.map
          (secret:
            lib.nameValuePair
              "plover/${secret}"
              (getKey secret))
          keys);
    in
    getSecrets [
      "ssh-key"
      "gitea/db/password"
    ];

  # All of the keys required to deploy the secrets. Don't know how to make the
  # GCP KMS key work though without manually going into the instance and
  # configure it there.
  sops.environment.SOPS_GCP_KMS_IDS = "projects/pivotal-sprite-295112/locations/global/keyRings/sops/cryptoKeys/plover-key";
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  # The main server where it will tie all of the services in one neat little
  # place.
  services.nginx = {
    enable = true;
    enableReload = true;
    package = pkgs.nginxMainline;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # Server blocks with no forcing of SSL are static sites so it is pretty
    # much OK.
    virtualHosts = {
      # Vaultwarden instance.
      "${passwordManagerDomain}" = {
        forceSSL = true;
        enableACME = true;
        locations = let
          address = config.services.vaultwarden.config.ROCKET_ADDRESS;
          port = config.services.vaultwarden.config.ROCKET_PORT;
          websocketPort = config.services.vaultwarden.config.WEBSOCKET_PORT;
        in {
          "/" = {
            proxyPass = "http://${address}:${toString port}";
            proxyWebsockets = true;
          };

          "/notifications/hub" = {
            proxyPass = "http://${address}:${toString websocketPort}";
            proxyWebsockets = true;
          };

          "/notifications/hub/negotiate" = {
            proxyPass = "http://${address}:${toString port}";
            proxyWebsockets = true;
          };
        };
      };

      # Gitea instance.
      "code.${config.networking.domain}" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:${toString config.services.gitea.httpPort}";
        };
      };
    };
  };

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };

  # Enable database services that is used in all of the services here so far.
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;

    # There's no database and user checks for Vaultwarden service.
    ensureDatabases = [ vaultwardenDbName ];
    ensureUsers = [
      {
        name = vaultwardenUser;
        ensurePermissions = { "DATABASE ${vaultwardenDbName}" = "ALL PRIVILEGES"; };
      }
    ];
  };

  # Time to harden...
  profiles.desktop.hardened-config.enable = true;

  # Generate them certificates.
  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@foodogsquared.one";
  };

  # Some additional dependencies for this system.
  environment.systemPackages = with pkgs; [
    asciidoctor
  ];

  # My code forge.
  services.gitea = {
    enable = true;
    appName = "foodogsquared's code forge";
    database = {
      passwordFile = config.sops.secrets."plover/gitea/db/password".path;
      type = "postgres";
    };
    lfs.enable = true;
    #mailerPasswordFile = config.sops.secrets."plover/gitea/smtp/password".path;

    settings = {
      "repository.pull_request" = {
        WORK_IN_PROGRESS_PREFIXES = "WIP:,[WIP],DRAFT,[DRAFT]";
        ADD_CO_COMMITTERS_TRAILERS = true;
      };

      ui = {
        EXPLORE_PAGING_SUM = 15;
        GRAPH_MAX_COMMIT_NUM = 200;
      };

      "ui.meta" = {
        AUTHOR = "foodogsquared's code forge";
        DESCRIPTION = ''
          foodogsquared's personal Git forge.
          Mainly personal projects and some archived and mirrored codebases.
        '';
        KEYWORDS = "foodogsquared,gitea,self-hosted";
      };

      # It's a personal instance so nah...
      service.DISABLE_REGISTRATION = true;

      repository = {
        ENABLE_PUSH_CREATE_USER = true;
        DEFAULT_PRIVATE = "public";
        DEFAULT_PRIVATE_PUSH_CREATE = true;
      };

      "markup.asciidoc" = {
        ENABLED = true;
        NEED_POSTPROCESS = true;
        FILE_EXTENSIONS = ".adoc,.asciidoc";
        RENDER_COMMANDS = "asciidoc --out-file=- -";
        IS_INPUT_FILE = false;
      };

      # Well, collaboration between forges is nice...
      federation.ENABLED = true;

      # Enable mirroring feature...
      mirror.ENABLED = true;

      other = {
        SHOW_FOOTER_VERSION = true;
        ENABLE_SITEMAP = true;
        ENABLE_FEED = true;
      };
    };
  };

  # An alternative implementation of Bitwarden written in Rust. The project
  # being written in Rust is a insta-self-hosting material right there.
  services.vaultwarden = {
    enable = true;
    dbBackend = "postgresql";
    config = {
      DOMAIN = "https://${passwordManagerDomain}";

      # Configuring the server.
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "critical";

      # Ehh... It's only a few (or even one) users anyways so nah. Since this
      # instance will not configure SMTP server, this pretty much means
      # invitation is only via email at this point.
      SHOW_PASSWORD_HINT = false;

      # Configuring some parts of account management which is almost
      # nonexistent because this is just intended for me (at least right now).
      SIGNUPS_ALLOWED = false;
      SIGNUPS_VERIFY = true;
      INVITATIONS_ALLOWED = true;

      # Notifications...
      WEBSOCKET_ENABLED = true;
      WEBSOCKET_PORT = 3012;
      WEBSOCKET_ADDRESS = "0.0.0.0";

      # Enabling web vault with whatever nixpkgs comes in.
      WEB_VAULT_ENABLED = true;
      WEB_VAULT_FOLDER = "${pkgs.vaultwarden-vault}/share/vaultwarden/vault";

      # Configuring the database.
      DATABASE_URL = "postgresql://${vaultwardenUser}:thisismadnessbutsomeonewilljustseethisanyways32342whaaaaaatthebloooooodyhell49@localhost/${vaultwardenDbName}";
    };
  };

  system.stateVersion = "22.11";
}
