{ config, lib, pkgs, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.programs.custom-homepage;

  settingsFormat = pkgs.formats.toml { };
in
{
  options.users.foo-dogsquared.programs.custom-homepage = {
    enable = lib.mkEnableOption "addition of custom homepage";

    sections = lib.mkOption {
      type = with lib.types; attrsOf settingsFormat.type;
      description = ''
        List of additional sections with their settings to be configured
        alongside the hardcoded sections.
      '';
      default = { };
      example = lib.literalExpression ''
        {
          services = {
            name = "Local services";
            flavorText = "for the local productivity";
            textOnly = true;

            links = lib.singleton {
              url = "localhost:''${builtins.toString config.services.mopidy.settings.port}";
              text = "Music streaming server";
            };
          };
        }
      '';
    };

    package = lib.mkOption {
      type = lib.types.package;
      description = ''
        The package derivation of the website.
      '';
      default = pkgs.callPackage ../../files/homepage/package.nix { };
    };

    finalPackage = lib.mkOption {
      type = lib.types.package;
      description = ''
        Output derivation containing the website with all of its modifications.
      '';
      readOnly = true;
    };
  };

  config = {
    users.foo-dogsquared.programs.custom-homepage.finalPackage =
      let
        data = lib.mapAttrs (n: v:
          settingsFormat.generate "fds-homepage-section-${n}" v) cfg.sections;

        installDataDir = lib.foldlAttrs (acc: n: v: ''
          ${acc}
          install -Dm0644 ${v} './data/foodogsquared-homepage/links/${n}.toml'
        '') "" data;
      in
      cfg.package.overrideAttrs (prevAttrs: {
        preBuild = (prevAttrs.preBuild or "") + ''
          ${installDataDir}
        '';
      });
  };
}
