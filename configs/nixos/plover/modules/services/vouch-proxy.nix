{ config, lib, pkgs, foodogsquaredLib, ... }:

let
  hostCfg = config.hosts.plover;
  cfg = hostCfg.services.vouch-proxy;

  inherit (config.services.vouch-proxy.instances."${vouchDomain}") settings;
  vouchDomain = "vouch.${config.networking.domain}";
  authDomain = config.services.kanidm.serverSettings.domain;
in
{
  options.hosts.plover.services.vouch-proxy.enable =
    lib.mkEnableOption "Vouch proxy setup";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      sops.secrets =
        let
          vouchPermissions = rec {
            owner = "vouch-proxy";
            group = owner;
            mode = "0400";
          };
        in
        foodogsquaredLib.sops-nix.getSecrets ../../secrets/secrets.yaml {
          "vouch-proxy/jwt/secret" = vouchPermissions;
          "vouch-proxy/client/secret" = vouchPermissions;
        };

      services.vouch-proxy = {
        enable = true;
        instances."${vouchDomain}".settings = {
          vouch = {
            listen = "127.0.0.1";
            port = 19900;

            domains = [ "foodogsquared.one" ];
            jwt.secret._secret = config.sops.secrets."vouch-proxy/jwt/secret".path;
          };

          oauth = rec {
            provider = "oidc";
            client_id = "vouch";
            client_secret._secret = config.sops.secrets."vouch-proxy/client/secret".path;
            code_challenge_method = "S256";
            auth_url = "https://${authDomain}/ui/oauth2";
            token_url = "https://${authDomain}/oauth2/token";
            user_info_url = "https://${authDomain}/oauth2/openid/${client_id}/userinfo";
            scopes = [ "openid" "email" "profile" ];
            callback_url = "https://${vouchDomain}/auth";
          };
        };
      };
    }

    (lib.mkIf hostCfg.services.reverse-proxy.enable {
      services.nginx.virtualHosts."${vouchDomain}" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        kTLS = true;
        locations."/" = {
          proxyPass = "http://vouch-proxy";
          extraConfig = ''
            proxy_set_header  Host  ${vouchDomain};
            proxy_set_header  X-Forwarded-Proto https;
          '';
        };
      };

      services.nginx.upstreams."vouch-proxy" = {
        extraConfig = ''
          zone services;
        '';
        servers = {
          "${settings.vouch.listen}:${builtins.toString settings.vouch.port}" = { };
        };
      };
    })
  ]);
}
