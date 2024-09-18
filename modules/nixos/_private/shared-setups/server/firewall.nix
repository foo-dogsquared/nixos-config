{ config, lib, pkgs, ... }:

let
  cfg = config.shared-setups.server.firewall;
in
{
  options.shared-setups.server.firewall.enable = lib.mkEnableOption "typical firewall setup";

  config = lib.mkIf cfg.enable {
    networking = {
      nftables.enable = true;
      firewall = {
        enable = true;
        allowedTCPPorts = [
          22 # Secure Shells.
        ];
      };
    };
  };
}
