{ config, lib, pkgs, foodogsquaredLib, ... }:

let
  hostCfg = config.hosts.ni;
  cfg = hostCfg.services.penpot;

  port = builtins.toString config.state.ports.penpot-frontend.value;
in
{
  options.hosts.ni.services.penpot.enable =
    lib.mkEnableOption "self-hosted Penpot design tool";

  config = lib.mkIf cfg.enable {
    state.ports = {
      penpot-frontend.value = 9001;
    };

    sops.secrets = foodogsquaredLib.sops-nix.getSecrets ./secrets.yaml {
      "penpot/env" = { };
    };

    virtualisation.oci-containers.networks.penpot = { };
    virtualisation.oci-containers.volumes.penpot_assets = { };
    virtualisation.oci-containers.volumes.penpot_postgres_v15 = { };

    virtualisation.oci-containers.containers.penpot-frontend = {
      image = "docker.io/penpotapp/frontend:latest";
      dependsOn = [
        "penpot-backend"
        "penpot-exporter"
      ];
      ports = lib.singleton "127.0.0.1:${port}:${port}";
      extraOptions = [
        "--network=penpot"
      ];
      volumes = [
        "penpot_assets:/opt/data/assets"
      ];
      environment.PENPOT_FLAGS = lib.concatStringsSep " " [
        "enable-login-with-password"
        "enable-webhooks"
        "enable-login-with-github"
        "enable-login-with-oidc"
        "disable-registration"
      ];
    };

    virtualisation.oci-containers.containers.penpot-backend = {
      image = "docker.io/penpotapp/backend:latest";
      volumes = [
        "penpot_assets:/opt/data/assets"
      ];
      extraOptions = [
        "--network=penpot"
      ];
      dependsOn = [
        "penpot-postgres"
        "penpot-redis"
      ];
      environmentFiles = [
        config.sops.secrets."penpot/env".path
      ];
      environment = {
        PENPOT_FLAGS = lib.concatStringsSep " " [
          "enable-registration"
          "enable-login-with-password"
        ];
        PENPOT_PUBLIC_URI = "http://localhost:${port}";
        PENPOT_DATABASE_URI = "postgresql://penpot-postgres/penpot";
        PENPOT_REDIS_URI = "redis://penpot-redis/0";
        PENPOT_ASSETS_STORAGE_BACKEND = "assets-fs";
        PENPOT_STORAGE_ASSETS_FS_DIRECTORY = "/opt/data/assets";
        PENPOT_TELEMETRY_ENABLED = "true";
      };
    };

    virtualisation.oci-containers.containers.penpot-exporter = {
      image = "docker.io/penpotapp/exporter:latest";
      extraOptions = [
        "--network=penpot"
      ];
      environment = {
        PENPOT_PUBLIC_URI = "http://penpot-frontend";
        PENPOT_REDIS_URI = "redis://penpot-redis/0";
      };
    };

    virtualisation.oci-containers.containers.penpot-redis = {
      image = "docker.io/redis:7";
      extraOptions = [
        "--network=penpot"
      ];
    };

    virtualisation.oci-containers.containers.penpot-postgres = {
      image = "docker.io/postgres:15";
      volumes = [
        "penpot_postgres_v15:/var/lib/postgresql/data"
      ];
      extraOptions = [ "--network=penpot" ];
      environment = {
        POSTGRES_INITDB_ARGS = lib.concatStringsSep " " [
          "--data-checksums"
        ];
        POSTGRES_DB = "penpot";
      };
    };
  };
}
