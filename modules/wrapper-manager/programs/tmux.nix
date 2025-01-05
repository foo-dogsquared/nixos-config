{ config, lib, pkgs, ... }:

let
  cfg = config.programs.tmux;
in
{
  options.programs.tmux = {
    enable = lib.mkEnableOption "configuring a tmux wrapper";

    package = lib.mkPackageOption pkgs "tmux" { };

    plugins = lib.mkOption {
      type = with lib.types; listOf (either package pluginSubmodule);
      description = ''
        List of tmux plugins to be included at your
        configuration.
      '';
      default = [ ];
      example = lib.literalExpression ''
        with pkgs; [
          tmuxPlugins.cpu
          {
            plugin = tmuxPlugins.resurrect;
            extraConfig = "set -g @resurrect-strategy-nvim 'session'";
          }
        ]
      '';
    };

    executableName = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "The wrapper's executable name.";
      default = "tmux-custom";
      example = "tmux-your-mom";
    };

    extraArgs = lib.mkOption {
      type = with lib.types; listOf str;
      description = ''
        List of arguments to be prepended to the user-given arguments.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    basePackage = cfg.package;

    wrappers.tmux = {
      inherit (cfg) executableName;
      prependArgs = cfg.extraArgs;
    };
  };
}
