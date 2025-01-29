{ config, lib, pkgs, ... }:

let cfg = config.shared-setups.server.fail2ban;
in {
  options.shared-setups.server.fail2ban.enable = lib.mkEnableOption
    "typical fail2ban configuration for public-facing servers";

  config = lib.mkIf cfg.enable {
    services.fail2ban = {
      enable = true;
      bantime-increment = {
        enable = true;
        factor = "4";
        maxtime = "24h";
        overalljails = true;
      };
      extraPackages = with pkgs; [ ipset ];

      # We're going to be unforgiving with this one since we only have key
      # authentication and password authentication is disabled anyways.
      jails.sshd.settings = {
        enabled = true;
        maxretry = 1;
      };
    };
  };
}
