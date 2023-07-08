{ config, lib, pkgs, ... }:

{
  sops.secrets = lib.getSecrets ./sops.yaml {
    ssh-key = { };
    "borg/ssh-key" = { };
    "wireguard/private-key" = {
      group = config.users.users.systemd-network.group;
      reloadUnits = [ "systemd-networkd.service" ];
      mode = "0640";
    };
  };
}
