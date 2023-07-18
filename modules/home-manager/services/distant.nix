{ config, options, lib, pkgs, ... }:

let
  cfg = config.services.distant;

  settingsFormat = pkgs.formats.toml {};
  settingsFile = settingsFormat.generate "distant-settings-${config.home.username}" cfg.settings;

  hasCustomSocketPath = cfg.settings.manager.unix_socket != null;
  defaultSocketPath = "%t/distant/%u.distant.sock";
in
{
  options.services.distant = {
    enable = lib.mkEnableOption "Distant manager";

    package = lib.mkOption {
      description = lib.mkDoc "The package containing the `distant` executable.";
      type = lib.types.package;
      default = pkgs.distant;
      defaultText = "pkgs.distant";
    };

    settings = lib.mkOption {
      description = lib.mkDoc ''
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
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.distant-manager = {
      Unit = {
        Description = "Distant manager daemon";
        Documentation = [ "https://distant.dev" ];
      };

      Service = {
        ExecStart = ''
          ${lib.getBin cfg.package}/bin/distant manager listen --config ${settingsFile} ${lib.optionalString (!hasCustomSocketPath) "--unix-socket ${defaultSocketPath}"}
        '';
        Restart = "on-failure";
        StandardInput = "socket";
      };

      Install.WantedBy = "default.target";
    };

    systemd.user.sockets.distant-manager = {
      Unit = {
        Description = "Distant manager daemon";
        Documentation = [ "https://distant.dev" ];
      };

      Socket.ListenStream = if hasCustomSocketPath then cfg.settings.manager.unix_socket else defaultSocketPath;
    };
  };
}
