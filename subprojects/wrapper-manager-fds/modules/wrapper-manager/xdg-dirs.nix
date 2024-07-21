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

          config.makeWrapperArgs =
            let
              # Just take note wrapper-specific values should be the one taking over.
              configDirs = cfg.configDirs ++ config.xdg.configDirs;
              dataDirs = cfg.dataDirs ++ config.xdg.dataDirs;
            in
            builtins.map (v: "--prefix 'XDG_CONFIG_DIRS' ':' ${v}") configDirs
            ++ (builtins.map (v: "--prefix 'XDG_DATA_DIRS' ':' ${v}") dataDirs);
        };
      in
      with lib.types; attrsOf (submodule xdgDirsType);
  };
}
