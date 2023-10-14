{ config, lib, pkgs, ... }:

# We're setting up Wezterm mux server with TLS domains.
let
  weztermDomain = "mux.${config.networking.domain}";
  port = 9801;
  listenAddress = "localhost:${builtins.toString port}";

  configFile = pkgs.substituteAll {
    src = ../../config/wezterm/config.lua;
    listen_address = listenAddress;
  };
in
{
  services.wezterm-mux-server = {
    enable = true;
    inherit configFile;
  };

  systemd.services.wezterm-mux-server = {
    requires = [ "acme-finished-${weztermDomain}.target" ];
    environment.WEZTERM_LOG = "info";
    serviceConfig = {
      LoadCredential =
        let
          certDir = config.security.acme.certs."${weztermDomain}".directory;
          credentialCertPath = path: "${path}:${certDir}/${path}";
        in
        [
          (credentialCertPath "key.pem")
          (credentialCertPath "cert.pem")
          (credentialCertPath "fullchain.pem")
        ];
    };
  };

  security.acme.certs."${weztermDomain}".postRun = ''
    systemctl restart wezterm-mux-server.service
  '';

  services.nginx.streamConfig = ''
    upstream wezterm {
      server ${listenAddress};
    }

    server {
      listen ${builtins.toString port};
      proxy_pass wezterm;
    }
  '';
}
