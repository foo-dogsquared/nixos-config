{ config, lib, pkgs, helpers, ... }:

let
  cfg = config.colorschemes.lush;

  schemeType = { config, lib, ... }: {
    options = {
      extraConfigLua = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = ''
          Theme-specific Lua code to be included for the colorscheme plugin.
          This is mainly useful for organizing the color palette in your
          preferred way.
        '';
      };

      highlights = lib.mkOption {
        type = with lib.types; attrsOf anything;
        default = { };
        description = ''
          The highlight group object to be exported with Lush. This is the data
          to be exported with `lush()` function from lush.nvim.
        '';
      };
    };
  };

  mkLushColorSchemes = name: theme:
    let
      # Converts each of the highlight group into a function to be able parsed and
      # used by Lush.
      highlightList =
        lib.mapAttrsToList
          (highlight: arguments: "${highlight}(${helpers.toLuaObject arguments})")
          theme.highlights;
    in
    # This is based from rktjmp/lush-template. We'll improve on things from
    # here whenever necessary.
    lib.nameValuePair "colors/${name}.lua" ''
      ${cfg.extraConfigLua}
      ${theme.extraConfigLua}

      vim.g.colors_name = '${name}'
      vim.o.termguicolors = true

      -- This needs to be parsed twice: once to generate the Lush spec
      -- and the other to actually apply the spec.
      --
      -- @diagnostic disable: undefined-global
      local spec = lush(function(injected_functions)
        local sym = injected_functions.sym
        return { ${lib.concatStringsSep "," highlightList} }
      end)

      -- We then apply the theme.
      lush(spec)
    '';
in
{
  options.colorschemes.lush = {
    enable = lib.mkEnableOption "theming with lush.nvim";

    package = helpers.mkPackageOption "lush.nvim" pkgs.vimPlugins.lush-nvim;

    extraConfigLua = lib.mkOption {
      type = lib.types.lines;
      default = ''
        local lush = require('lush')
      '';
      example = ''
        local lush = require('lush')
        local hsl = lush.hsl
        local hsluv = lush.hsluv
      '';
      description = ''
        Additional Lua code to be prepended before the Lush theme export.
      '';
    };

    themes = lib.mkOption {
      type = with lib.types; attrsOf (submodule schemeType);
      description = ''
        A set of Lush-created themes. Each of these themes is to be exported as
        a colorscheme plugin to NixVim usable with
        {option}`colorscheme`.

        It can serve as an alternative to {option}`colorschemes.base16` or the
        colorscheme plugins if you want a framework for creating more
        expressive colorschemes.
      '';
      default = { };
      example = {
        "example-theme".highlights = {
          Normal = {
            fg.__raw = "hsluv('#300000')";
            bg.__raw = "hsluv('#600000')";
          };
          CursorLine.bg.__raw = "Normal.bg.lighten(5)";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    extraPlugins = [ cfg.package ];

    extraFiles =
      lib.mapAttrs' mkLushColorSchemes cfg.themes;
  };
}
