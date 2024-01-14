{ config, lib, pkgs, ... }:

let
  hostCfg = config.hosts.plover;
  cfg = hostCfg.services.firewall;
in
{
  options.hosts.plover.services.firewall.enable = lib.mkEnableOption "firewall setup";

  config = lib.mkIf cfg.enable {
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
  };
}
