# This is a terrible idea (at least from the app developer's perspective)
# because what we're doing is a massive hack. We're essentially instilling a
# forced isolated environment for the settings backend to look into. This will
# go downhill very badly once the dconf-enabled wrapper has mismatched
# configuration with the wider environment. Once that occurred, this is a
# problem neither the app developer nor the system maintainers are to blame but
# the user. So yeah, it is terrible to put this into wrapper-manager-fds
# upstream and it may be here for the rest of time.
#
# In other words, dconf is just not built for this case.
{ config, lib, pkgs, ... }:

let
  cfg = config.dconf;

  settingsFormat = {
    type = with lib.types;
      let
        valueType = (oneOf [ bool float int str (listOf valueType) ]) // {
          description = "dconf value";
        };
      in attrsOf (attrsOf valueType);

    generate = name: value:
      pkgs.writeTextDir "/dconf/${name}" (lib.generators.toDconfINI value);
  };

  dconfModuleFactory = { isGlobal ? false }: {
    enable = lib.mkEnableOption "configuration with dconf"
      // lib.optionalAttrs (!isGlobal) { default = cfg.enable; };

    package = lib.mkPackageOption pkgs "dconf" { }
      // lib.optionalAttrs (!isGlobal) { default = cfg.package; };

    settings = lib.mkOption {
      type = settingsFormat.type;
      default = { };
      description = if isGlobal then ''
        Global settings to be applied per dconf-enabled wrapper.
      '' else ''
        The settings of the dconf database that the wrapper uses.
      '';
      example = lib.literalExpression ''
        {
          "org/gnome/nautilus/list-view".use-tree-view = true;
          "org/gnome/nautilus/preferences".show-create-link = true;
          "org/gtk/settings/file-chooser" = {
            sort-directories-first = true;
            show-hidden = true;
          };
        }
      '';
    };

    keyfiles = lib.mkOption {
      type = with lib.types; listOf path;
      description = if isGlobal then ''
        Global list of keyfiles to be included to each dconf-enabled wrapper.
      '' else ''
        Additional list of keyfiles to be included as part of the dconf
        database.
      '';
      default = if isGlobal then [ ] else [ "user-db" ];
      example = lib.literalExpression ''
        [
          ./config/dconf/90-extra-settings.conf
        ]
      '';
    };

    profile = lib.mkOption {
      type = with lib.types; listOf str;
      description = if isGlobal then ''
        Global list of dconf database that will be used for each dconf-enabled
        wrappers.
      '' else ''
        A list of dconf databases that will be used for the main dconf
        profile of the dconf-configured wrapper.
      '';
      default = [ "user-db:user" ];
      defaultText = ''
        "user-db:user" as the writeable database alongside the generated
        database file from our settings.
      '';
    };
  };
in {
  options.dconf = dconfModuleFactory { isGlobal = true; };

  options.wrappers = let
    dconfSubmodule = { config, lib, name, ... }:
      let
        submoduleCfg = config.dconf;

        dconfProfileFile = pkgs.writeText "dconf-profile" (lib.concatMapStrings
          (db: ''
            ${db}
          '') submoduleCfg.profile);

        dconfSettings = settingsFormat.generate
          "wrapper-manager-dconf-${config.executableName}-settings"
          submoduleCfg.settings;

        keyfilesDir = pkgs.symlinkJoin {
          name = "wrapper-manager-dconf-${config.executableName}";
          paths = submoduleCfg.keyfiles ++ [ "${dconfSettings}/dconf" ];
        };

        dconfSettingsDatabase = pkgs.runCommand
          "wrapper-manager-dconf-${config.executableName}-database" {
            nativeBuildInputs = [ submoduleCfg.package ];
          } ''
            dconf compile ${builtins.placeholder "out"} "${keyfilesDir}"
          '';
      in {
        options.dconf = dconfModuleFactory { isGlobal = false; } // {
          databaseDrv = lib.mkOption {
            type = lib.types.package;
            description = ''
              Derivation containing the compiled dconf database. Useful for
              integrating with your own module.
            '';
            readOnly = true;
          };
        };

        config = lib.mkIf submoduleCfg.enable {
          env.DCONF_PROFILE.value = dconfProfileFile;

          dconf = {
            profile = lib.mkMerge [
              cfg.profile

              (lib.mkAfter [ (builtins.toString submoduleCfg.databaseDrv) ])
            ];
            keyfiles = cfg.keyfiles;
            settings = cfg.settings;
            databaseDrv = dconfSettingsDatabase;
          };
        };
      };
  in lib.mkOption {
    type = with lib.types; attrsOf (submodule dconfSubmodule);
  };
}
