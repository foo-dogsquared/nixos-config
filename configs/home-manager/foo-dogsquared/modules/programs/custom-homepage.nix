{ config, lib, pkgs, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.programs.custom-homepage;

  settingsFormat = pkgs.formats.toml { };
  themesSettingsFormat = pkgs.formats.yaml { };
in {
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

    themes = lib.mkOption {
      type = with lib.types; attrsOf path;
      description = ''
        Set of [Tinted Theming Base16
        palettes](https://github.com/tinted-theming) to be exported to the
        homepage.

        ::: {.note}
        As such, they are assumed to be all YAML files.
        :::
      '';
      default = { };
      example = lib.literalExpression ''
        {
          _dark = ./files/base16/bark-on-a-tree.yml;
          _light = ./files/base16/albino-bark-on-a-tree.yml;

          catpuccin-mocha = (pkgs.formats.yaml { }).generate "catpuccin-mocha-base16" {
            system = "base16";
            name = "Catppuccin Mocha";
            author = "https://github.com/catppuccin/catppuccin";
            variant = "dark";
            palette = {
              base00 = "1e1e2e";
              base01 = "181825";
              base02 = "313244";
              base03 = "45475a";
              base04 = "585b70";
              base05 = "cdd6f4";
              base06 = "f5e0dc";
              base07 = "b4befe";
              base08 = "f38ba8";
              base09 = "fab387";
              base0A = "f9e2af";
              base0B = "a6e3a1";
              base0C = "94e2d5";
              base0D = "89b4fa";
              base0E = "cba6f7";
              base0F = "f2cdcd";
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
    users.foo-dogsquared.programs.custom-homepage.finalPackage = let
      data = lib.mapAttrs
        (n: v: settingsFormat.generate "fds-homepage-section-${n}" v)
        cfg.sections;

      installDataDir = lib.foldlAttrs (acc: n: v: ''
        ${acc}
        install -Dm0644 ${v} './data/foodogsquared-homepage/links/${n}.toml'
      '') "" data;

      installThemes = lib.foldlAttrs (acc: n: v: ''
        ${acc}
        install -Dm0644 ${v} './data/foodogsquared-homepage/themes/${n}}.yaml
      '') "" cfg.themes;
    in cfg.package.overrideAttrs (prevAttrs: {
      preBuild = (prevAttrs.preBuild or "") + ''
        ${installDataDir}
        ${installThemes}
      '';
    });

    xdg.dataFile."foodogsquared/homepage".source = cfg.finalPackage;
  };
}
