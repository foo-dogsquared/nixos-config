{ config, options, lib, pkgs, ... }:

let
  cfg = config.programs.epiphany;

  webAppsSubmodule = { name, config, ... }: {
    options = {
      url = lib.mkOption {
        type = lib.types.str;
        description = ''
          The URL of the web app.
        '';
        example = "https://editor.graphite.rs";
      };

      name = lib.mkOption {
        type = lib.types.str;
        default = name;
        description = ''
          The entry name of the desktop file generated for the web app.
        '';
        example = "Graphite";
      };
    };
  };
in
{
  options.programs.epiphany = {
    enable = lib.mkEnableOption "configuring Epiphany web browser";

    package = lib.mkPackageOption pkgs "epiphany" { };

    settings = lib.mkOption {
      type = options.dconf.settings.type;
      default = { };
      description = ''
        dconf settings for Epiphany to be set under the `org/gnome/epiphany`
        namespace.
      '';
      apply =
        let
          updateAttr = acc: n: v:
            if (lib.isAttrs v) then
              acc // { "org/gnome/epiphany/${n}" = v; }
            else
              lib.recursiveUpdate acc { "org/gnome/epiphany" = v; };
        in lib.foldlAttrs updateAttr { };
      example = lib.literalExpression ''
        {
          homepage-url = "file://''${config.xdg.dataHome}/''${config.username}/homepage/index.html";

          web = {
            remember-passwords = true;
            enable-user-css = true;
            enable-user-js = true;
          };
        }
      '';
    };

    webApps = lib.mkOption {
      type = with lib.types; attrsOf (submodule webAppsSubmodule);
      default = { };
      description = ''
        A set of web apps to be installed with Epiphany and DBus.
      '';
      example = lib.literalExpression ''
        {
          penpot = {
            url = "https://design.penpot.app";
            name = "Penpot";
          };
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = [ cfg.package ];

      dconf.settings = cfg.settings;
    }

    (lib.mkIf (cfg.webApps != { }) {
      # TODO Install web apps through Dbus
      # Set up the web app provider.
      # Create a install token from somewhere(?).
      systemd.user.services.epiphany-web-app-provider = {
        Unit = {
          Description = "Epiphany web app provider service";
        };

        Service.ExecStart = "${cfg.package}/libexec/epiphany-webapp-provider";

        Install.WantedBy = [ "default.target" ];
      };

      home.activation.installEpiphanyWebApps = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      '';
    })
  ]);
}
