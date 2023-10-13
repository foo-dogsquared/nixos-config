{ config, lib, pkgs, ... }:

let
  inherit (config.services.vouch-proxy.instances."${vouchDomain}") settings;
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
        auth_url = "${authDomain}/ui/oauth2";
        token_url = "${authDomain}/oauth2/token";
        user_info_url = "${authDomain}/oauth2/openid/${client_id}/userinfo";
        scopes = [ "login" "email" ];
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
      proxyPass = "http://vouch-proxy";
      extraConfig = ''
        proxy_set_header  Host  ${vouchDomain};
        proxy_set_header  X-Forwarded-Proto https;
      '';
    };
  };

  services.nginx.upstreams."vouch-proxy" = {
    extraConfig = ''
      zone apps;
    '';
    servers = {
      "${settings.vouch.listen}:${builtins.toString settings.vouch.port}" = { };
    };
  };
}
