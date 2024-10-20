{ config, lib, pkgs, foodogsquaredLib, ... }:

let
  hostCfg = config.hosts.plover;
  cfg = hostCfg.services.grafana;

  monitoringDomain = "monitoring.${config.networking.domain}";

  authDomain = "auth.${config.networking.domain}";
  authSubpath = path: "${authDomain}/${path}";

  vouchDomain = "vouch.${config.networking.domain}";
  vouchSettings =
    config.services.vouch-proxy.instances."${vouchDomain}".settings;
in {
  options.hosts.plover.services.grafana.enable =
    lib.mkEnableOption "monitoring dashboard for ${config.networking.hostName}";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      state.ports.grafana.value = 3000;

      sops.secrets = let
        grafanaFileAttributes = {
          owner = config.users.users.grafana.name;
          group = config.users.users.grafana.group;
          mode = "0400";
        };
      in foodogsquaredLib.sops-nix.getSecrets ../../secrets/secrets.yaml {
        "grafana/database/password" = grafanaFileAttributes;
        "grafana/users/admin/password" = grafanaFileAttributes;
      };

      services.grafana = {
        enable = true;

        settings = {
          auth = {
            disable_login_form = true;
            login_maximum_inactive_lifetime_duration = "3d";
            login_maximum_lifetime_duration = "14d";
          };

          log = {
            level = "warn";
            mode = "syslog";
          };

          security = {
            admin_email = config.security.acme.defaults.email;
            admin_password = "$__file{${
                config.sops.secrets."grafana/users/admin/password".path
              }}";
            cookie_secure = true;
            csrf_trusted_origins =
              [ vouchDomain "auth.${config.networking.domain}" ];
            strict_transport_security = true;
            strict_transport_security_subdomains = true;
          };

          users = {
            default_theme = "system";
            default_language = "detect";
          };

          server = {
            enable_gzip = true;
            enforce_domain = true;
            http_addr = "127.0.0.1";
            http_port = config.state.ports.grafana.value;
            root_url = "${monitoringDomain}/grafana";
            serve_from_sub_path = true;
          };
        };
      };
    }

    (lib.mkIf hostCfg.services.reverse-proxy.enable {
      services.nginx.virtualHosts."${monitoringDomain}" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;

        extraConfig = ''
          auth_request /validate;

          # If the user is not logged in, redirect them to Vouch's login URL
          error_page 401 = @error401;
          location @error401 {
            return 302 http://vouch-proxy/login?url=$scheme://$http_host$request_uri&vouch-failcount=$auth_resp_failcount&X-Vouch-Token=$auth_resp_jwt&error=$auth_resp_err;
          }
        '';

        locations = {
          "= /validate" = {
            proxyPass = "http://vouch-proxy";
            extraConfig = ''
              proxy_pass_request_body off;
              proxy_set_header Content-Length "";

              # These will be passed to @error_401 call.
              auth_request_set $auth_resp_x_vouch_user $upstream_http_x_vouch_user;
              auth_request_set $auth_resp_jwt $upstream_http_x_vouch_jwt;
              auth_request_set $auth_resp_err $upstream_http_x_vouch_err;
              auth_request_set $auth_resp_failcount $upstream_http_x_vouch_failcount;
            '';
          };

          # Make Grafana as the default to be redirected.
          "= /".return = "301 /grafana";

          # Serving Grafana with a subpath.
          "/grafana" = {
            proxyPass = "http://grafana";
            extraConfig = ''
              proxy_set_header X-Vouch-User $auth_resp_x_vouch_user;
            '';
          };
        };
      };

      services.nginx.upstreams."grafana" = {
        extraConfig = ''
          zone services;
        '';
        servers = {
          "localhost:${
            builtins.toString config.services.grafana.settings.server.http_port
          }" = { };
        };
      };

    })

    (lib.mkIf hostCfg.services.database.enable {
      services.postgresql = let
        grafanaDatabaseName = config.services.grafana.settings.database.name;
      in {
        ensureDatabases = [ grafanaDatabaseName ];
        ensureUsers = lib.singleton {
          name = grafanaDatabaseName;
          ensureDBOwnership = true;
        };
      };

      services.grafana.settings = {
        database = rec {
          host =
            "127.0.0.1:${builtins.toString config.services.postgresql.port}";
          password =
            "$__file{${config.sops.secrets."grafana/database/password".path}}";
          type = "postgres";
          name = "grafana";
          user = name;
        };
      };
    })

    (lib.mkIf hostCfg.services.vouch-proxy.enable {
      sops.secrets = let
        grafanaFileAttributes = {
          owner = config.users.users.grafana.name;
          group = config.users.users.grafana.group;
          mode = "0400";
        };
      in foodogsquaredLib.sops-nix.getSecrets ../../secrets/secrets.yaml {
        "grafana/oauth_client_secret" = grafanaFileAttributes;
      };

      services.grafana.settings."auth.generic_oauth" = {
        enabled = true;
        name = "Kanidm";
        client_id = "grafana";
        client_secret =
          "$__file{${config.sops.secrets."grafana/oauth_client_secret".path}}";
        allow_sign_up = true;
        use_pkce = true;
        use_refresh_token = true;
        oauth_url = authSubpath "ui/oauth2";
        token_url = authSubpath "oauth2/token";
        api_url = authSubpath "oauth2/openid/grafana/userinfo";
        login_attribute_path = "preferred_username";
        groups_attribute_path = "groups";
        role_attribute_path = ''
          contains(grafana_role[*], 'GrafanaAdmin') && 'GrafanaAdmin' || contains(grafana_role[*], 'Admin') && 'Admin' || contains(grafana_role[*], 'Editor') && 'Editor' || 'Viewer'
        '';
        allow_assign_grafana_admin = true;
        scopes =
          lib.concatStringsSep " " [ "openid" "email" "profile" "groups" ];
      };
    })
  ]);
}
