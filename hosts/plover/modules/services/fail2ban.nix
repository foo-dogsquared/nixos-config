{ config, lib, pkgs, ... }:

let
  hostCfg = config.hosts.plover;
  cfg = hostCfg.services.fail2ban;

  inherit (import ../hardware/networks.nix) interfaces;
in
{
  options.hosts.plover.services.fail2ban.enable = lib.mkEnableOption "fail2ban monitoring";

  config = lib.mkIf cfg.enable {
    services.fail2ban = {
      enable = true;
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
  };
}
