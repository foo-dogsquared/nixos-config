{ config, lib, pkgs, ... }:

let
  cfg = config.services.distant;

  settingsFormat = pkgs.formats.toml { };
  settingsFile = settingsFormat.generate "distant-settings-${config.home.username}" cfg.settings;

  hasCustomSocketPath = cfg.settings.manager.unix_socket != null;
  defaultSocketPath = "%t/distant/%u.distant.sock";
in
{
  options.services.distant = {
    enable = lib.mkEnableOption "Distant-related services";

    package = lib.mkOption {
      description = "The package containing the {command}`distant` executable.";
      type = lib.types.package;
      default = pkgs.distant;
      defaultText = "pkgs.distant";
    };

    settings = lib.mkOption {
      description = ''
        The configuration settings to be passed to the service.
      '';
      types = settingsFormat.type;
      default = { };
      defaultText = "{}";
      example = lib.literalExpression ''
        {
          manager.unix_socket = "/path/to/socket.sock";
        }
      '';
    };

    manager.enable = lib.mkEnableOption "Distant manager daemon";
    server.enable = lib.mkEnableOption "Distant server daemon";
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.distant-manager = lib.mkIf cfg.manager.enable {
      Unit = {
        Description = "Distant manager daemon";
        Documentation = [ "https://distant.dev" ];
      };

      Service = {
        ExecStart = ''
          ${lib.getBin cfg.package}/bin/distant manager listen --config ${settingsFile} ${lib.optionalString (!hasCustomSocketPath) "--unix-socket ${defaultSocketPath}"}
        '';
        Restart = "on-failure";
      };

      Install.WantedBy = "default.target";
    };

    systemd.user.sockets.distant-manager = lib.mkIf cfg.manager.enable {
      Unit = {
        Description = "Distant manager daemon";
        Documentation = [ "https://distant.dev" ];
      };

      Socket.ListenStream = if hasCustomSocketPath then cfg.settings.manager.unix_socket else defaultSocketPath;
    };

    systemd.user.services.distant-server = lib.mkIf cfg.server.enable {
      Unit = {
        Description = "Distant manager daemon";
        Documentation = [ "https://distant.dev" ];
      };

      Service = {
        ExecStart = ''
          ${lib.getBin cfg.package}/bin/distant server listen --config ${settingsFile}
        '';
        Restart = "on-failure";
        StandardInput = "socket";
      };

      Install.WantedBy = "default.target";
    };
  };
}
