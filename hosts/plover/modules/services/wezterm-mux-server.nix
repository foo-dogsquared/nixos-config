{ config, lib, pkgs, ... }:

# We're setting up Wezterm mux server with TLS domains.
let
  hostCfg = config.hosts.plover;
  cfg = hostCfg.services.wezterm-mux-server;

  weztermDomain = "mux.${config.networking.domain}";
  port = 9801;
  listenAddress = "localhost:${builtins.toString port}";

  configFile = pkgs.substituteAll {
    src = ../../config/wezterm/config.lua;
    listen_address = listenAddress;
  };
in
{
  options.hosts.plover.services.wezterm-mux-server.enable = lib.mkEnableOption "Wezterm mux server setup";

  config = lib.mkIf cfg.enable (lib.mkMerge [
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
    }

    # TODO: where mux.foodogsquared.one setup
    (lib.mkIf hostCfg.services.reverse-proxy.enable {
      services.nginx.streamConfig = ''
        upstream wezterm {
          server ${listenAddress};
        }

        server {
          listen ${builtins.toString port};
          proxy_pass wezterm;
        }
      '';
    })
  ]);
}
