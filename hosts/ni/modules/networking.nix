{ config, lib, pkgs, ... }:

{
  # Be a networking doctor or something.
  programs.mtr.enable = true;

  # Wanna be a wannabe haxxor, kid?
  programs.wireshark.package = pkgs.wireshark;

  # Modern version of SSH.
  programs.mosh.enable = true;

  # Just supporting local systems, businesses, and business systems.
  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };

  # We'll go with a software firewall. We're mostly configuring it as if we're
  # using a server even though the chances of that is pretty slim.
  networking = {
    nftables.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # Secure Shells.
      ];
    };
  };

  services.resolved.domains = [
    "~plover.foodogsquared.one"
    "~0.27.172.in-addr.arpa"
    "~0.28.172.in-addr.arpa"
  ];
}
