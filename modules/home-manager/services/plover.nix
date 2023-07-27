{ config, options, lib, pkgs, ... }:

let
  cfg = config.services.plover;

  toPloverINI = with lib;
    generators.toINI {
      mkKeyValue = generators.mkKeyValueDefault
        {
          mkValueString = v:
            if v == true then
              "True"
            else if v == false then
              "False"
            else
              generators.mkValueStringDefault { } v;
        } " = ";
    };

  ploverIniFormat = {}: {
    type = (pkgs.formats.ini { }).type;
    generate = name: value: pkgs.writeText name (toPloverINI value);
  };

  settingsFormat = ploverIniFormat { };
in
{
  options.services.plover = {
    enable = lib.mkEnableOption "Plover stenography engine service";

    package = lib.mkOption {
      type = lib.types.package;
      description = "The derivation containing the binaries for the service.";
      default = pkgs.plover.dev;
      defaultText = "pkgs.plover.dev";
      example = lib.literalExpression "pkgs.plover.stable";
    };

    settings = lib.mkOption {
      type = settingsFormat.type;
      description = "Configuration to be used for the application.";
      default = { };
      defaultText = lib.literalExpression "{}";
      example = lib.literalExpression ''
        {
          "Output Configuration" = {
            undo_levels = 100;
          };

          "Stroke Display" = {
            show = true;
          };
        }
      '';
    };

    extraOptions = lib.mkOption {
      type = with lib.types; listOf str;
      description =
        "Extra command-line arguments to pass to {command}`plover`";
      default = [ ];
      defaultText = lib.literalExpression "[]";
      example = lib.literalExpression ''
        [ "--gui none" ]
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "services.plover" pkgs
        lib.platforms.linux)
    ];

    home.packages = [ cfg.package ];

    xdg.configFile."plover/plover.cfg".source =
      settingsFormat.generate "plover-config-${config.home.username}"
        cfg.settings;

    systemd.user.services.plover = {
      Unit = {
        Description = "Plover stenography engine";
        Documentation = [ "https://github.com/openstenoproject/plover/wiki/" ];
        PartOf = "default.target";
      };

      Service = {
        ExecStart = "${cfg.package}/bin/plover ${
            lib.concatStringsSep " " cfg.extraOptions
          }";
      };

      Install.WantedBy = [ "default.target" ];
    };
  };
}
