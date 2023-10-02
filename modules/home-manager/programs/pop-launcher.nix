{ config, lib, pkgs, ... }:

let
  cfg = config.programs.pop-launcher;

  # Plugins and scripts are assumed to be packaged at
  # `$out/share/pop-launcher`.
  pluginsDir = pkgs.symlinkJoin {
    name = "pop-launcher-plugins-system";
    paths = builtins.map (p: "${p}/share/pop-launcher") cfg.plugins;
  };
in
{
  options.programs.pop-launcher = {
    enable = lib.mkOption {
      description = ''
        Whether to enable Pop launcher, a launcher service for application
        launchers.

        Take note you have to install an application launcher frontend to make
        use of this such as {command}`onagre` or
        {command}`cosmic-launcher`.
      '';
      type = lib.types.bool;
      default = false;
      example = true;
    };

    package = lib.mkOption {
      type = lib.types.package;
      description = ''
        The package where {command}`pop-launcher` binary and
        built-in plugins are expected.

        ::: {.note}
        The package is assumed to have been patched to search for the
        derivation output path (at `$out/share/pop-launcher`) instead of the
        distribution plugins path (at `/usr/lib/pop-launcher`). Otherwise, the
        built-in plugins will not show up in the launcher frontend.
        :::
      '';
      default = pkgs.pop-launcher;
    };

    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      description = ''
        List of packages containing Pop launcher plugins and scripts to be
        installed as system-wide plugins. The launcher plugins and scripts of
        each listed package are assumed to be installed at
        `$out/share/pop-launcher`.
      '';
      default = [ ];
      defaultText = "[]";
      example = lib.literalExpression ''
        with pkgs; [
          pop-launcher-plugin-duckduckgo-bangs
          pop-launcher-plugin-jetbrains
        ];
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # The local plugin path is hardcoded so we'll also do that instead of
    # properly setting in `xdg.dataFile`.
    home.file.".local/share/pop-launcher".source = pluginsDir;

    home.packages = [ cfg.package ];
  };
}
