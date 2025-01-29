{ config, lib, pkgs, ... }:

let cfg = config.suites.vpn;
in {
  options.suites.vpn = {
    personal.enable =
      lib.mkEnableOption "personal VPN configuration with Wireguard";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.personal.enable {
      services.tailscale.enable = true;
      networking = {
        nameservers = [ "100.100.100.100" "8.8.8.8" "1.1.1.1" ];
        search = [ "barbel-bee.ts.net" ];
      };
    })
  ];
}
