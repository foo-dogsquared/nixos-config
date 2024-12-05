{ config, lib, pkgs, foodogsquaredLib, ... }:

let
  hostCfg = config.users.foo-dogsquared;
  cfg = hostCfg.services.archivebox;

  inherit (config.home) homeDirectory;
  port = config.state.ports.archivebox.value;
in
{
  options.users.foo-dogsquared.services.archivebox.enable =
    lib.mkEnableOption "ArchiveBox web UI server (through Podman)";

  config = lib.mkIf cfg.enable {
    state.ports = {
      archivebox.value = 8932;
      sonic.value = 9141;
    };

    sops.secrets = foodogsquaredLib.sops.getSecrets ./secrets.yaml {
      "archivebox/env" = { };
      "sonic/env" = { };
    };

    services.podman.containers.archivebox-webui = {
      image = "archivebox/archivebox:latest";
      description = "ArchiveBox web server";
      ports = [ "${port}:${port}" ];
      volumes = [
        "${config.xdg.userDirs.documents}/ArchiveBox:/data"
      ];
      autoUpdate = "registry";
      exec = "archivebox server localhost:${port}";
      environmentFile = [ "${config.sops.secrets."archivebox/env".path}" ];
      environment = {
        SEARCH_BACKEND_ENGINE = "sonic";
        SEARCH_BACKEND_HOST_NAME = "sonic";
        PUBLIC_SNAPSHOTS = false;
        PUBLIC_INDEX = false;
        PUBLIC_ADD_VIEW = false;
      };
    };

    services.podman.containers.archivebox-sonic-search = {
      image = "archivebox/sonic:latest";
      description = "Sonic search instance for ArchiveBox";
      ports = let
        port = config.state.ports.sonic.value;
      in [ "${port}:${port}" ];
      environmentFile = [ "${config.sops.secrets."sonic/env".path}" ];
      volumes = [
        "${config.xdg.userDirs.documents}/ArchiveBox/Sonic:/var/lib/sonic/store"
        "${./config/sonic/sonic.cfg}:/etc/sonic.cfg:ro"
      ];
    };
  };
}
