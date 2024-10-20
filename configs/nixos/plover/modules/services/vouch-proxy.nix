{ config, lib, pkgs, foodogsquaredLib, ... }:

let
  hostCfg = config.hosts.plover;
  cfg = hostCfg.services.vouch-proxy;

  inherit (config.services.vouch-proxy.instances."${vouchDomain}") settings;
  inherit (config.networking) domain;
  vouchDomain = "vouch.${config.networking.domain}";
  authDomain = config.services.kanidm.serverSettings.domain;
in {
  options.hosts.plover.services.vouch-proxy.enable =
    lib.mkEnableOption "Vouch proxy setup";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      state.ports = { "vouch-proxy-${domain}".value = 19900; };

      sops.secrets = let
        vouchPermissions = rec {
          owner = "vouch-proxy";
          group = owner;
          mode = "0400";
        };
      in foodogsquaredLib.sops-nix.getSecrets ../../secrets/secrets.yaml {
        "vouch-proxy/domains/${domain}/jwt-secret" = vouchPermissions;
        "vouch-proxy/domains/${domain}/client-secret" = vouchPermissions;
      };

      services.vouch-proxy = {
        enable = true;
        instances."${vouchDomain}".settings = {
          vouch = {
            listen = "127.0.0.1";
            port = config.state.ports."vouch-proxy-${domain}".value;

            domains = [ "foodogsquared.one" ];
            jwt.secret._secret =
              config.sops.secrets."vouch-proxy/domains/${domain}/jwt-secret".path;
            cookie.secure = true;
          };

          oauth = let authSubpath = path: "https://${authDomain}/${path}";
          in rec {
            provider = "oidc";
            client_id = "vouch";
            client_secret._secret =
              config.sops.secrets."vouch-proxy/domains/${domain}/client-secret".path;
            code_challenge_method = "S256";
            auth_url = authSubpath "ui/oauth2";
            token_url = authSubpath "oauth2/token";
            user_info_url = authSubpath "oauth2/openid/${client_id}/userinfo";
            scopes = [ "openid" "email" "profile" ];
            callback_url = authSubpath "auth";
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
          zone vouch-proxy 64k;
          keepalive 2;
        '';
        servers = {
          "${settings.vouch.listen}:${builtins.toString settings.vouch.port}" =
            { };
        };
      };
    })
  ]);
}
