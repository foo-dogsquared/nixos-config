{ config, lib, pkgs, ... }:

let
  cfg = config.services.ctrld;

  settingsFormat = pkgs.formats.toml { };
  settingsFile = settingsFile.generate "ctrld-proxy-settings" cfg.settings;
in
{
  options.services.ctrld = {
    enable = lib.mkEnableOption "ctrld, a DNS forwarding proxy";
    package = lib.mkPackageOption pkgs "ctrld" { };

    settings = lib.mkOption {
      type = settingsFormat.type;
      description = ''
        Settings to be used for the ctrld server.
      '';
      default = { };
      example = lib.literalExpression ''
        {
          service = {
            log_level = "info";
            log_path = "";
            cache_enable = true;
            cache_size = 4096;
            cache_ttl_override = 60;
            cache_serve_stale = true;
          };

          "upstream.0" = {
            bootstrap_ip = "76.76.2.11";
            endpoint = "https://freedns.controld.com/p1";
            name = "Control D - Anti-Malware";
            timeout = 5000;
            type = "doh";
            ip_stack = "both";
          };

          "network.0" = {
            cidrs = ["0.0.0.0/0"];
            name = "Everyone";
          };
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.ctrld = {
      description = "Forwarding DNS proxy";
      script = ''
        ${lib.getExe' cfg.package "ctrld"} run --config ${settingsFile}
      '';
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "default.target" ];

      serviceConfig = {
        User = "ctrld";
        Group = "ctrld";
        DynamicUser = true;

        Restart = "on-failure";
        LockPersonality = true;
        NoNewPrivileges = true;

        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];

        # TODO: ProtectProc=?
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "full";
        RestrictAddressFamilies = [
          "AF_LOCAL"
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        SystemCallArchitectures = [ "native" ];
        SystemCallFilter = [ "@system-service" ];
      };
    };
  };
}
