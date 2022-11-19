{ config, options, lib, pkgs, ... }:

let
  cfg = config.programs.pop-launcher;

  # This assumes the package contains the built-in plugins being symlinked to
  # the main binary with absolute paths. Most sensibly, the nixpkgs builder
  # will rewrite symlinks relative to its output directory. Since we're putting
  # them outside of its output directory, we'll have to stop it from doing
  # that.
  package = cfg.package.overrideAttrs (prev: {
    dontRewriteSymlinks = true;
  });

  # Some plugins may be packaged ala-busybox with multiple plugins coming from
  # the same binary. Similar reasons as to why we don't want to rewrite
  # symlinks with the main package.
  plugins = lib.map
    (p: p.overrideAttrs (prev: {
      dontRewriteSymlinks = true;
    }))
    cfg.plugins;

  # Plugins and scripts are assumed to be packaged at
  # `$out/share/pop-launcher`.
  pluginsDir = pkgs.symlinkJoin {
    name = "pop-launcher-plugins-system";
    paths = builtins.map (p: "${p}/share/pop-launcher") (plugins ++ [ package ]);
  };
in
{
  options.programs.pop-launcher = {
    enable = lib.mkOption {
      description = ''
        Whether to enable Pop launcher, a launcher service for application
        launchers.

        Take note you have to install an application launcher frontend to make
        use of this such as <command>onagre</command> or
        <command>cosmic-launcher</command>.
      '';
      type = lib.types.bool;
      default = false;
      example = true;
    };

    package = lib.mkOption {
      type = lib.types.package;
      description = ''
        The package where <command>pop-launcher</command> binary and
        built-in plugins are expected.
      '';
      default = pkgs.pop-launcher;
    };

    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      description = ''
        List of packages containing Pop launcher plugins and scripts to be
        installed as system-wide plugins.
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

    home.packages = [ package ];
  };
}
