# Essentially a derivative of nix-colors module that closely follows Tinted
# Theming "standard" and can hold multiple palettes suitable for generating
# multiple configuration files for organization purposes.
{ pkgs, lib, bahaghariLib, ... }:

let
  inherit (bahaghariLib.tinted-theming) isBase24 isBase16;

  settingsFormat = pkgs.formats.yaml { };

  # This follows the schema of a Tinted Theming scheme. Its support for legacy
  # Base16 theme is pretty awful for now. Anyways. this would allow a simple
  # `bahaghariLib.importYAML` and wam-bam-thank-you-mam.
  #
  # For future reference, you can take a look at the schemes schema at
  # https://github.com/tinted-theming/home/blob/a6d697844a40350a3b3f3d231f68530a180e3f0e/builder.md
  schemeType = { name, config, lib, ... }: {
    # This would allow extensions to the schema if the scheme author or the
    # user wants to add some.
    freeformType = settingsFormat.type;

    options = {
      # The builder will be the one to detect these properly. Though, we could
      # also detect this ourselves as well... but with Nixlang? REALLY!?!
      system = lib.mkOption {
        type = with lib.types; nullOr (enum [ "base16" "base24" ]);
        default = if (isBase24 config.palette) then
          "base24"
        else if (isBase16 config.palette) then
          "base16"
        else
          null;
        example = "base24";
        description = ''
          Indicates which system this scheme supports. This is mainly on the
          builder to properly detect this.
        '';
      };

      author = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = "Scheme Author";
        example = "You (ME?)";
        description = ''
          The scheme author's readable name.
        '';
      };

      name = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = name;
        example = "Bark on a tree";
        description = ''
          The human-readable name of the scheme.
        '';
      };

      description = lib.mkOption {
        type = with lib.types; nullOr str;
        default = null;
        example = "Rusty theme inspired from the forestry (and Nord theme).";
        description = "A short description of the theme.";
      };

      variant = lib.mkOption {
        type = with lib.types; nullOr (enum [ "dark" "light" ]);
        default = null;
        example = "light";
        description = ''
          The variant of the theme. This is typically associated with already
          existing standards such as the FreeDesktop appearance preferences or
          Vim `background` settings.
        '';
      };

      palette = lib.mkOption {
        type = with lib.types;
          attrsOf (coercedTo str (lib.removePrefix "#") str);
        default = { };
        example = {
          base00 = "2b221f";
          base01 = "412c26";
          base02 = "5c362c";
          base03 = "a45b43";
          base04 = "e1bcb2";
          base05 = "f5ecea";
          base06 = "fefefe";
          base07 = "eb8a65";
          base08 = "d03e68";
          base09 = "df937a";
          base0A = "afa644";
          base0B = "85b26e";
          base0C = "eb914a";
          base0D = "c67f62";
          base0E = "8b7ab9";
          base0F = "7f3F83";
        };
        description = ''
          A set of colors. For this module, we place a small additional
          restriction in here that all attributes should be a string. It is
          common to set colors in HTML hex format.
        '';
      };
    };
  };
in {
  options.bahaghari.tinted-theming = {
    schemes = lib.mkOption {
      type = with lib.types; attrsOf (submodule schemeType);
      default = { };
      example = {
        "bark-on-a-tree" = {
          system = "base16";
          name = "Bark on a tree";
          author = "Gabriel Arazas";
          description = ''
            Rusty and woody theme inspired from forestry (and Nord theme).
          '';
          variant = "dark";
          palette = rec {
            background = base00;
            foreground = base05;
            base00 = "2b221f";
            base01 = "412c26";
            base02 = "5c362c";
            base03 = "a45b43";
            base04 = "e1bcb2";
            base05 = "f5ecea";
            base06 = "fefefe";
            base07 = "eb8a65";
            base08 = "d03e68";
            base09 = "df937a";
            base0A = "afa644";
            base0B = "85b26e";
            base0C = "eb914a";
            base0D = "c67f62";
            base0E = "8b7ab9";
            base0F = "7f3F83";
          };
        };
      };
      description = ''
        A set of [Tinted Theming](https://github.com/tinted-theming) schemes.
        You can set the palette to whatever criteria you deem suitable but this
        module closely follows the main standards with this theming ecosystem
        (specifically Base16 and Base24).

        The most common palette scheme is Base16 where the colors are set from
        `base00` to `base0F`. Some themes could have 24-colors variant or have
        additional meaningful names (e.g., `foreground`, `background`).
      '';
    };
  };
}
