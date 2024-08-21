{ config, lib, pkgs, ... }:

let
  cfg = config.services.wezterm-mux-server;
in
{
  options.services.wezterm-mux-server = {
    enable = lib.mkEnableOption "Wezterm mux server";

    package = lib.mkOption {
      type = lib.types.package;
      description = ''
        The package containing the {command}`wezterm-mux-server` binary.
      '';
      default = pkgs.wezterm;
      defaultText = "pkgs.wezterm";
    };

    configFile = lib.mkOption {
      type = with lib.types; nullOr path;
      description = ''
        The path to the configuration file. For more information, you can see
        [its section for setting up multiplexing](https://wezfurlong.org/wezterm/multiplexing.html).
      '';
      default = null;
      defaultText = "null";
      example = lib.literalExpression "./wezterm-mux-server.lua";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.wezterm-mux-server = {
      description = "Wezterm mux server";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      path = [ cfg.package ];

      wantedBy = [ "multi-user.target" ];
      script = ''
        wezterm-mux-server ${lib.optionalString (cfg.configFile != null) "--config-file ${cfg.configFile}"}
      '';

      # Give it some tough love.
      serviceConfig = {
        User = config.users.users.wezterm.name;
        Group = config.users.groups.wezterm.name;
        UMask = "0077";

        Restart = "on-failure";

        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        SystemCallFilter = [
          "@system-service"
          "~@cpu-emulation"
          "~@keyring"
          "~@module"
          "~@privileged"
        ];
        SystemCallErrorNumber = "EPERM";
        SystemCallArchitectures = "native";
        RestrictRealtime = true;
        RestrictSUIDSGID = true;

        WorkingDirectory = config.users.users.wezterm.home;
        StateDirectory = "wezterm";
        RuntimeDirectory = "wezterm";

        # Restricting what capabilities this service has.
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];

        # Restrict what address families this service can interact with.
        # Wezterm mux server mostly expects it to interact with the internet
        # families and makes use of Unix sockets.
        RestrictAddressFamilies = [
          # Practically required as it uses Unix sockets.
          "AF_LOCAL"

          # The internet class families.
          "AF_INET"
          "AF_INET6"
        ];

        # Restrict what namespaces it can create which is none.
        RestrictNamespaces = true;
      };
    };

    users.users.wezterm = {
      description = "Wezterm system user";
      home = "/var/lib/wezterm";
      createHome = true;
      group = config.users.groups.wezterm.name;
      isSystemUser = true;
      shell = pkgs.runtimeShell;
    };

    users.groups.wezterm = { };
  };
}
