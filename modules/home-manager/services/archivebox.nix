{ config, options, lib, pkgs, ... }:

let
  cfg = config.services.archivebox;
in {
  options.services.archivebox = {
    enable = lib.mkEnableOption "Archivebox service";

    port = lib.mkOption {
      type = lib.types.port;
      description = "The port number to be used for the server at localhost.";
      default = 8000;
      example = 8888;
    };

    archivePath = lib.mkOption {
      type = with lib.types; either path str;
      description = "The path of the Archivebox archive.";
      example = "\${config.xdg.dataHome}/archivebox";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.archivebox ];
    systemd.user.services.archivebox-server = {
      Unit = {
        Description = "Archivebox server for ${cfg.archivePath}";
        After = "network.target";
        Documentation = [ "https://docs.archivebox.io/" ];
      };

      Install.WantedBy = [ "graphical-session.target" ];

      Service = {
        ExecStart = "${pkgs.archivebox}/bin/archivebox server localhost:${toString cfg.port}";
        WorkingDirectory = cfg.archivePath;
        Restart = "on-failure";
      };
    };
  };
}
