{ config, lib, pkgs, ... }:

let
  inherit (config.services.vouch-proxy) settings;
  vouchDomain = "vouch.${config.networking.domain}";
  authDomain = config.services.kanidm.serverSettings.domain;
in
{
  sops.secrets = lib.getSecrets ../../secrets/secrets.yaml {
    "vouch-proxy/jwt/secret" = { };
    "vouch-proxy/client/secret" = { };
  };

  services.vouch-proxy = {
    enable = true;
    settings = {
      vouch = {
        listen = "127.0.0.1";
        port = 19900;

        domains = [ "foodogsquared.one" ];
        jwt.secret._secret = config.sops.secrets."vouch-proxy/jwt/secret".path;
      };

      oauth = rec {
        provider = "oidc";
        client_id = "kanidm";
        client_secret._secret = config.sops.secrets."vouch-proxy/client/secret".path;
        auth_url = "${authDomain}/ui/oauth2";
        token_url = "${authDomain}/oauth2/token";
        user_info_url = "${authDomain}/oauth2/openid/${client_id}/userinfo";
        scopes = [ "login" ];
        callback_url = "https://${vouchDomain}/auth";
      };
    };
  };

  services.nginx.virtualHosts."${vouchDomain}" = {
    forceSSL = true;
    enableACME = true;
    acmeRoot = null;
    kTLS = true;
    locations."/" = {
      proxyPass = "http://${settings.vouch.listen}:${builtins.toString settings.vouch.port}";
      extraConfig = ''
        proxy_set_header  Host  ${vouchDomain};
        proxy_set_header  X-Forwarded-Proto https;
      '';
    };
  };
}
