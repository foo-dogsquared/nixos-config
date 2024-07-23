{ config, lib, ... }:

let
  cfg = config.xdg;

  xdgDirsOption = {
    configDirs = lib.mkOption {
      type = with lib.types; listOf str;
      description = ''
        A list of paths to be appended as part of the `XDG_CONFIG_DIRS`
        environment to be applied per-wrapper.
      '';
      default = [ ];
      example = lib.literalExpression ''
        wrapperManagerLib.getXdgConfigDirs (with pkgs; [
          yt-dlp
          neofetch
        ])
      '';
    };

    dataDirs = lib.mkOption {
      type = with lib.types; listOf str;
      description = ''
        A list of paths to be appended as part of the `XDG_DATA_DIRS`
        environment to be applied per-wrapper.
      '';
      default = [ ];
      example = lib.literalExpression ''
        wrapperManagerLib.getXdgDataDirs (with pkgs; [
          yt-dlp
          neofetch
        ])
      '';
    };
  };
in
{
  options.xdg = xdgDirsOption;

  options.wrappers = lib.mkOption {
    type =
      let
        xdgDirsType = { name, lib, config, ... }: {
          options.xdg = xdgDirsOption;

          # When set this way, we could allow the user to override everything.
          config.xdg.configDirs = cfg.configDirs;
          config.xdg.dataDirs = cfg.dataDirs;

          config.makeWrapperArgs =
            builtins.map (v: "--prefix 'XDG_CONFIG_DIRS' ':' ${v}") config.xdg.configDirs
            ++ (builtins.map (v: "--prefix 'XDG_DATA_DIRS' ':' ${v}") config.xdg.dataDirs);
        };
      in
      with lib.types; attrsOf (submodule xdgDirsType);
  };
}
