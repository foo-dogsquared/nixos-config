{ config, lib, pkgs, ... }:

let
  monitoringDomain = "monitoring.${config.networking.domain}";
  authDomain = "auth.${config.networking.domain}";
  authSubpath = path: "${authDomain}/${path}";

  vouchDomain = "vouch.${config.networking.domain}";
  vouchSettings = config.services.vouch-proxy.instances."${vouchDomain}".settings;

  certDir = file: "${config.security.acme.certs."${monitoringDomain}".directory}/${file}";
  inherit (config.services.grafana) settings;
in
{
  services.grafana = {
    enable = true;

    settings = {
      auth = {
        disable_login_form = true;
        login_maximum_inactive_lifetime_duration = "3d";
        login_maximum_lifetime_duration = "14d";
      };

      "auth.generic_oauth" = {
        api_url = authSubpath "oauth2/authorise";
        client_id = "grafana";
        client_secret = "$_file{${config.sops.secrets."vouch-proxy/client/secret".path}";
        enabled = true;
        name = "Kanidm";
        oauth_url = authSubpath "ui/oauth2";
        scopes = lib.concatStringsSep " " [ "openid" "email" "profile" ];
        token_url = authSubpath "oauth2/token";
      };

      database = {
        host = "127.0.0.1:${builtins.toString config.services.postgresql.port}";
        password = "$_file{${config.sops.secrets."grafana/database/password".path}}";
        type = "postgres";
        user = config.services.grafana.database.name;
      };

      log = {
        level = "warn";
        mode = "syslog";
      };

      security = {
        admin_email = config.security.acme.defaults.email;
        admin_password = "$_file{${config.sops.secrets."grafana/users/admin/password".path}}";
        cookie_secure = true;
        csrf_trusted_origins = [
          vouchDomain
          "auth.${config.networking.domain}"
        ];
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
        http_port = 3000;
        root_url = "${monitoringDomain}/grafana";
        serve_from_sub_path = true;
      };
    };
  };

  services.nginx.virtualHosts."${monitoringDomain}" = {
    forceSSL = true;
    enableACME = true;
    acmeRoot = null;

    extraConfig = ''
      auth_request /validate;

      # If the user is not logged in, redirect them to Vouch's login URL
      error_page 401 = @error401;
      location @error401 {
        return 302 http://${vouchDomain}/login?url=$scheme://$http_host$request_uri&vouch-failcount=$auth_resp_failcount&X-Vouch-Token=$auth_resp_jwt&error=$auth_resp_err;
      }
    '';

    locations = {
      "= /validate" = {
        proxyPass = "http://${vouchSettings.vouch.listen}:${builtins.toString vouchSettings.vouch.port}";
        extraConfig = ''
          proxy_pass_request_body off;

          # These will be passed to @error_401 call.
          auth_request_set $auth_resp_x_vouch_user $upstream_http_x_vouch_user;
          auth_request_set $auth_resp_jwt $upstream_http_x_vouch_jwt;
          auth_request_set $auth_resp_err $upstream_http_x_vouch_err;
          auth_request_set $auth_resp_failcount $upstream_http_x_vouch_failcount;
        '';
      };

      # Make Grafana as the default to be redirected.
      "= /".return = "/grafana";

      # Serving Grafana with a subpath.
      "/grafana" = {
        proxyPass = "http://${settings.server.http_addr}:${builtins.toString settings.server.http_port}";
        extraConfig = ''
          proxy_set_header X-Vouch-User $auth_resp_x_vouch_user;
        '';
      };
    };
  };

  # Setting up with secure schema usage pattern.
  systemd.services.grafana = {
    preStart =
      let
        grafanaDatabaseUser = config.services.grafana.settings.database.user;
        psql = lib.getExe' config.services.postgresql.package "psql";
      in
      lib.mkBefore ''
        # Setting up the appropriate schema for PostgreSQL secure schema usage.
        ${psql} -tAc "SELECT 1 FROM information_schema.schemata WHERE schema_name='${grafanaDatabaseUser}';" \
          grep -q 1 || ${psql} -tAc "CREATE SCHEMA IF NOT EXISTS AUTHORIZATION ${grafanaDatabaseUser};"
      '';
  };

  sops.secrets =
    let
      grafanaFileAttributes = {
        owner = config.users.users.grafana.name;
        group = config.users.users.grafana.group;
        mode = "0400";
      };
    in
    lib.getSecrets ../../secrets/secrets.yaml {
      "grafana/database/password" = grafanaFileAttributes;
      "grafana/users/admin/password" = grafanaFileAttributes;
    };
}
