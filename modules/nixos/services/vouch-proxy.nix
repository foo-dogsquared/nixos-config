{ config, lib, pkgs, utils, ... }:

let
  cfg = config.services.vouch-proxy;
  settingsFormat = pkgs.formats.yaml { };

  instanceType = { name, config, options, ... }: {
    options = {
      package = lib.mkPackageOption pkgs "vouch-proxy" { };

      settings = lib.mkOption {
        description = ''
          Configuration to be passed to Vouch Proxy.

          ::: {.note}
          For settings with sensitive values like JWT token secret, you can
          specify a `_secret` attribute with a path value. In the final version
          of the generated settings, the key will have the value with the
          content of the specified path.
          :::
        '';
        type = settingsFormat.type;
        default = { };
        example = lib.literalExpression ''
          {
            vouch = {
              listen = "127.0.0.1";
              port = 30746;
              domains = [ "gitea.example.com" ];
              allowAllUsers = true;
              jwt.secret._secret = "/path/to/jwt-secret";
              session.key._secret = "/path/to/session-key-secret";
            };

            oauth = {
              provider = "github";
              client_id = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
              client_secret._secret = "/path/to/secret";
              auth_url = "https://gitea.example.com/login/oauth/authorize";
              token_url = "https://gitea.example.com/login/oauth/access_token";
              user_info_url = "https://gitea.example.com/api/v1/user?token=";
              callback_url = "https://example.com/auth";
            };
          }
        '';
      };

      settingsFile = lib.mkOption {
        type = with lib.types; nullOr path;
        default = null;
        defaultText = lib.literalExpression "settingsFile";
        description = ''
          The path of the configuration file. If `null`, it uses the
          filepath from NixOS-generated settings.
        '';
        example = lib.literalExpression "/etc/vouch-proxy/config.yml";
      };
    };
  };

  mkVouchInstance = name: instance:
    let
      inherit (instance) settings settingsFile;
      settingsFile' = "/var/lib/vouch-proxy/${name}-config.yml";
    in lib.nameValuePair "vouch-proxy-${utils.escapeSystemdPath name}" {
      preStart = if (settings != { } && settingsFile == null) then ''
        ${pkgs.writeScript "vouch-proxy-replace-secrets"
        (utils.genJqSecretsReplacementSnippet settings settingsFile')}
        chmod 0600 "${settingsFile'}"
      '' else ''
        install -Dm0600 "${settingsFile}" "${settingsFile'}"
      '';
      script = "${
          lib.getExe' instance.package "vouch-proxy"
        } -config ${settingsFile'}";
      serviceConfig = {
        User = config.users.users.vouch-proxy.name;
        Group = config.users.groups.vouch-proxy.name;

        Restart = "on-failure";
        RestartSec = 5;

        PrivateTmp = true;
        PrivateDevices = true;

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        RestrictSUIDSGID = true;
        RestrictRealtime = true;
        ProtectClock = true;
        ProtectKernelLogs = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectHostname = true;
        ProtectControlGroups = true;
        ProtectProc = "invisible";
        ProcSubset = "pid";

        SystemCallFilter = [
          "@system-service"
          "~@cpu-emulation"
          "~@keyring"
          "~@module"
          "~@privileged"
          "~@reboot"
        ];
        SystemCallErrorNumber = "EPERM";
        SystemCallArchitectures = "native";

        RuntimeDirectory = "vouch-proxy";
        StateDirectory = "vouch-proxy";

        # Restricting what capabilities this service has.
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];

        # Limit this service to Unix sockets and IPs.
        RestrictAddressFamilies = [ "AF_LOCAL" "AF_INET" "AF_INET6" ];
        RestrictNamespaces = true;
      };
      wantedBy = [ "multi-user.target" ];
    };
in {
  options.services.vouch-proxy = {
    enable =
      lib.mkEnableOption "Vouch Proxy, a proxy for SSO and OAuth/OIDC logins";

    instances = lib.mkOption {
      type = with lib.types; attrsOf (submodule instanceType);
      description = "Instances of Vouch proxy to be run.";
      default = { };
      example = lib.literalExpression ''
        {
          "vouch.example.com".settings = {
            vouch = {
              listen = "127.0.0.1";
              port = 19900;

              domains = [ "example.com" ];
              jwt.secret._secret = "/var/lib/secrets/vouch-proxy-jwt-secret";
            };

            oauth = rec {
              provider = "oidc";
              client_id = "vouch";
              client_secret._secret = "/var/lib/secrets/vouch-proxy-client-secret";
              code_challenge_method = "S256";
              auth_url = "https://auth.example.com/ui/oauth2";
              token_url = "https://auth.example.com/oauth2/token";
              user_info_url = "https://auth.example.com/oauth2/openid/$''${client_id}/userinfo";
              scopes = [ "login" "email" ];
              callback_url = "https://auth.example.com/auth";
            };
          };
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services = lib.mapAttrs' mkVouchInstance cfg.instances;

    users.users.vouch-proxy = {
      description = "Vouch Proxy user";
      group = config.users.groups.vouch-proxy.name;
      isSystemUser = true;
    };

    users.groups.vouch-proxy = { };
  };
}
