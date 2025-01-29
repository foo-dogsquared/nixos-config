{ lib, pkgs, config, ... }:

let cfg = config.programs.zellij;
in {
  options.programs.zellij = {
    enable = lib.mkEnableOption "Zellij, a terminal multiplexer";

    package = lib.mkPackageOption pkgs "zellij" { };

    configFile = lib.mkOption {
      type = lib.types.path;
      description = ''
        The configuration file of the Zellij wrapper to be used. This module
        will use the environment variable `ZELLIJ_CONFIG_FILE` which would
        still allow overriding of the user's own if they choose to.
      '';
      example = lib.literalExpression ''
        ./config/zellij/config.kdl
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    basePackages = [ cfg.package ];
    wrappers.zellij = {
      arg0 = lib.getExe' cfg.package "zellij";
      env.ZELLIJ_CONFIG_FILE.value = cfg.configFile;
    };
  };
}
