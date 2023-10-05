{ config, lib, pkgs, ... }:

let
  cfg = config.services.wezterm-mux-server;

  defaultUser = "wezterm";
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

    user = lib.mkOption {
      type = lib.types.str;
      default = defaultUser;
      defaultText = defaultUser;
      description = ''
        User account of the Wezterm mux server. It is recommended to change
        this with a dedicated user account intended to be accessed through SSH.
      '';
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = defaultUser;
      defaultText = defaultUser;
      description = ''
        The group which the Wezterm mux server runs under. It is recommended to
        change this with a dedicated user group intended to be accessed through
        SSH.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    users.users = lib.mkIf (cfg.user == defaultUser) {
      "${defaultUser}" = {
        description = "Wezterm mux service";
        home = "/home/wezterm";
        useDefaultShell = true;
        group = cfg.group;
        isSystemUser = true;
      };
    };

    users.groups = lib.mkIf (cfg.group == defaultUser) {
      "${defaultUser}" = { };
    };

    systemd.services.wezterm-mux-server = {
      description = "Wezterm mux server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      script = "${lib.getExe' cfg.package "wezterm-mux-server"} ${lib.optionalString (cfg.configFile != null) "--config-file ${cfg.configFile}"}";

      # Give it some tough love.
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;

        LockPersonality = true;
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

        RuntimeDirectory = "wezterm";
        CacheDirectory = "wezterm";
        StateDirectory = "wezterm";

        # Restricting what capabilities this service has.
        CapabilityBoundingSet = [ "" ];
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
  };
}
