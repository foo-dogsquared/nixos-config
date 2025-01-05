{ config, lib, pkgs, ... }:

let
  cfg = config.fonts;

  fontsModuleFactory = { isGlobal ? false }: {
    enable = lib.mkEnableOption "local fonts support" // {
      default = if isGlobal then false else cfg.enable;
    };

    packages = lib.mkOption {
      type = with lib.types; listOf package;
      description =
        if isGlobal then ''
          Global list of fonts to be added per wrapper (with the local fonts
          support enabled anyways).
        '' else ''
          List of fonts to be added to the wrapper.
        '';
      default = [ ];
      example = lib.literalExpression ''
        with pkgs; [
          noto-sans
          source-sans-pro
          source-code-pro
          stix
        ]
      '';
    };
  };
in
{
  options.fonts = fontsModuleFactory { isGlobal = true; };

  wrappers =
    let
      fontsSubmodule = { config, lib, name, pkgs, ... }: let
        submoduleCfg = config.fonts;
      in {
        options.fonts = fontsModuleFactory { isGlobal = false; };

        config = let
          fontCache = pkgs.makeFontsCache {
            inherit (pkgs) fontconfig;
            fontsDirectories = submoduleCfg.packages;
          };
        in lib.mkIf submoduleCfg.enable {
          fonts.packages = cfg.packages;
        };
      };
    in lib.mkOption {
      type = with lib.types; attrsOf (submodule fontsSubmodule);
    };
}
