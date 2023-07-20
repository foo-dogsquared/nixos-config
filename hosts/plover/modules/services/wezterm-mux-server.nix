{ config, lib, pkgs, ... }:

# We're setting up Wezterm mux server with TLS domains.
let
  weztermDomain = "mux.${config.networking.domain}";
  configFile = pkgs.substituteAll {
    src = ../../config/wezterm/config.lua;
    CERT_DIR = config.security.acme.certs."${weztermDomain}".directory;
  };
in
{
  services.wezterm-mux-server = {
    inherit configFile;
    enable = true;
  };

  security.acme.certs."${weztermDomain}" = {
    group = "wezterm";
    postRun = ''
      systemctl restart wezterm-mux-server.service
    '';
  };
}
