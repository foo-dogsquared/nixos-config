# Basically a poor man's version of NixVim or those configuration options from
# either NixOS or home-manager, really.
{ config, lib, pkgs, ... }:

let
  cfg = config.programs.neovim;

  neovimConfigPluginType = { name, lib, ... }: {
    freeformType = with lib.types; attrsOf anything;
    options = {
      plugin = lib.mkOption {
        type = lib.types.package;
        description = ''
          Package containing the Neovim module.
        '';
      };

      pluginConfig = lib.mkOption {
        type = lib.types.lines;
        description = ''
          Plugin configuration in VimL.
        '';
        default = "";
      };

      optional = lib.mkEnableOption "inclusion of this configuration";
    };
  };

  neovimConfig = pkgs.neovimUtils.makeNeovimConfig {
    inherit (cfg) plugins extraPython3Packages extraLuaPackages;
    wrapRc = true;
    withRuby = cfg.providers.ruby.enable;
    withNodeJs = cfg.providers.nodejs.enable;
    withPython = cfg.providers.python.enable;
  };

  finalNeovimPackage = pkgs.wrapNeovimUnstable cfg.package neovimConfig;
in
{
  options.programs.neovim = {
    enable = lib.mkEnableOption "Neovim, a terminal text editor";

    package = lib.mkPackageOption pkgs "neovim-unwrapped" { };

    executableName = lib.mkOption {
      type = lib.types.str;
      description = ''
        The name of the executable name. Pretty useful for creating multiple
        Neovim packages.
      '';
      default = "nvim";
      example = "nvim-foodogsquared";
    };

    plugins = lib.mkOption {
      type = with lib.types; listOf (submodule neovimConfigPluginType);
      description = ''
        List of Neovim plugins to be included within the wrapper.
      '';
      default = [ ];
      example = lib.literalExpression ''
        [
          { plugin = pkgs.vimPlugins.vim-nickel; }
        ]
      '';
    };

    extraPython3Packages = lib.mkOption {
      type = with lib.types; functionTo (listOf package);
      description = ''
        A function containing an extra list of Python packages to be included
        in the Neovim installation.
      '';
      default = _: [ ];
      example = lib.literalExpression ''
        p: with p; [
          numpy
        ]
      '';
    };

    extraLuaPackages = lib.mkOption {
      type = with lib.types; functionTo (listOf package);
      description = ''
        A function containing an extra list of Lua packages to be included
        within the Neovim installation.
      '';
      default = _: [ ];
      example = lib.literalExpression ''
        p: with p; [
          lz-n
        ]
      '';
    };

    providers = {
      python.enable = lib.mkEnableOption "Python provider with Neovim";
      nodejs.enable = lib.mkEnableOption "NodeJS provider with Neovim";
      ruby.enable = lib.mkEnableOption "Ruby provider with Neovim";
    };
  };

  config = lib.mkIf cfg.enable {
    basePackages = finalNeovimPackage;

    wrappers.nvim = {
      executableName = cfg.executableName;
      arg0 = lib.getExe' finalNeovimPackage "nvim";
    };
  };
}
