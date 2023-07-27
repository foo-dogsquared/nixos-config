{ config, lib, pkgs, ... }:

# We're setting up Wezterm mux server with TLS domains.
let
  weztermDomain = "mux.${config.networking.domain}";
in
{
  services.wezterm-mux-server = {
    enable = true;
    configFile = ../../config/wezterm/config.lua;
  };

  systemd.services.wezterm-mux-server.serviceConfig = {
    LoadCredential = let
      certDir = config.security.acme.certs."${weztermDomain}".directory;
      credentialCertPath = path: "${path}:${certDir}/${path}";
    in
    [
      (credentialCertPath "key.pem")
      (credentialCertPath "cert.pem")
      (credentialCertPath "fullchain.pem")
    ];
  };

  security.acme.certs."${weztermDomain}".postRun = ''
    systemctl restart wezterm-mux-server.service
  '';
}
