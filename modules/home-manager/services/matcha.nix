{ config, lib, pkgs, ... }:

let
  cfg = config.services.matcha;

  settingsFormat = pkgs.formats.yaml { };
  settingsFile = settingsFormat.generate "matcha-config" cfg.settings;
in
{
  options.services.matcha = {
    enable = lib.mkEnableOption "Matcha periodic feed digest generator";

    package = lib.mkOption {
      description = ''
        The package containing the {command}`matcha` executable.
      '';
      type = lib.types.package;
      default = pkgs.matcha;
      defaultText = "pkgs.matcha";
    };

    settings = lib.mkOption {
      description = ''
        The configuration to be used with the Matcha service.
      '';
      type = settingsFormat.type;
      default = { };
      defaultText = "{}";
      example = lib.literalExpression ''
        {
          markdown_dir_path = "''${config.xdg.userDirs.documents}/Matcha";
          feeds = [
            "http://hnrss.org/best 10"
            "https://waitbutwhy.com/feed"
            "http://tonsky.me/blog/atom.xml"
            "http://www.joelonsoftware.com/rss.xml"
            "https://www.youtube.com/feeds/videos.xml?channel_id=UCHnyfMqiRRG1u-2MsSQLbXA"
          ];
          opml_file_path = "''${config.xdg.userDirs.documents}/feeds.opml";
        }
      '';
    };

    startAt = lib.mkOption {
      description = ''
        How often the service generates the digest.

        The value is used to `Calendar.OnCalendar` systemd timer option. For
        more details about the value format, see {manpage}`systemd.time(7)`.
      '';
      type = lib.types.str;
      default = "daily";
      example = "weekly";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.matcha = {
      Unit = {
        Description = "Matcha periodic feed digest generator";
        Documentation = [ "https://github.com/piqoni/matcha" ];
      };

      Install.WantedBy = [ "default.target" ];

      Service = {
        ExecStart = "${cfg.package}/bin/matcha -c ${settingsFile}";
        Restart = "on-failure";
      };
    };

    systemd.user.timers.matcha = {
      Unit = {
        Description = "Matcha periodic feed digest generator";
        Documentation = [ "https://github.com/piqoni/matcha" ];
        After = [ "network.target" ];
      };
      Install.WantedBy = [ "timers.target" ];
      Timer = {
        Persistent = true;
        OnCalendar = cfg.startAt;
      };
    };
  };
}
