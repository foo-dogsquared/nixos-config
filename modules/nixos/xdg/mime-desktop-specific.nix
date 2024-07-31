{ config, lib, options, ... }:

let
  cfg = config.xdg.mime;

  mkMimeSource = name: value:
    lib.nameValuePair
      "xdg/${name}-mimeapps.list"
      (lib.mkIf (value.defaultApplications != { }) {
        text = lib.generators.toINI { } {
          "Default Applications" = value.defaultApplications;
        };
      });

  xdgMimeAssociations = { name, lib, ... }: {
    options.defaultApplications = options.xdg.mime.defaultApplications;
  };
in
{
  options.xdg.mime.desktops = lib.mkOption {
    type = with lib.types; attrsOf (submodule xdgMimeAssociations);
    description = ''
      Additional desktop-specific associations.

      ::: {.note}
      This can only specify default applications for a specific MIME type and
      cannot be used to remove or add associations.
      :::
    '';
    default = { };
    example = {
      gnome.defaultApplications = {
        "application/pdf" = "firefox.desktop";
      };
    };
  };

  config = lib.mkIf (cfg.desktops != { }) {
    environment.etc =
      lib.mapAttrs' mkMimeSource cfg.desktops;
  };
}
