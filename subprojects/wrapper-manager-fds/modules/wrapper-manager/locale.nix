{ config, lib, pkgs, ... }:

let
  cfg = config.locale;

  localeModuleFactory = { isGlobal ? false }: {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = if isGlobal then true else cfg.enable;
      description = if isGlobal then ''
        Whether to enable explicit glibc locale support. This is recommended
        for Nix-built applications.
      '' else ''
        Whether to enable locale support for this wrapper. Recommended for
        Nix-built applications.
      '';
    };

    package = lib.mkOption {
      type = lib.types.package;
      default =
        if isGlobal
        then (pkgs.glibcLocales.override { allLocales = true; })
        else cfg.package;
      description = ''
        The package containing glibc locales.
      '';
    };
  };
in
{
  options.locale = localeModuleFactory { isGlobal = true; };

  options.wrappers =
    let
      localeSubmodule = { config, lib, name, ... }: let
        submoduleCfg = config.locale;
      in {
        options.locale = localeModuleFactory { isGlobal = false; };

        config = lib.mkIf submoduleCfg.enable {
          env.LOCALE_ARCHIVE.value = "${submoduleCfg.package}/lib/locale/locale-archive";
        };
      };
    in
      lib.mkOption {
        type = with lib.types; attrsOf (submodule localeSubmodule);
      };
}
