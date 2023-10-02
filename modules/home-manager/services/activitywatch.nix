{ config, lib, pkgs, ... }:

let
  cfg = config.services.activitywatch;

  mkWatcherService = name: cfg:
    let
      jobName = "activitywatch-watcher-${cfg.name}";
    in
    lib.nameValuePair jobName {
      Unit = {
        Description = "ActivityWatch watcher '${cfg.name}'";
        After = [ "activitywatch.service" ];
        BindsTo = [ "activitywatch.target" ];
      };

      Service = {
        ExecStart = "${cfg.package}/bin/${cfg.executable} ${lib.escapeShellArgs cfg.extraArgs}";
        Restart = "on-failure";

        # Some sandboxing.
        LockPersonality = true;
        NoNewPrivileges = true;
        RestrictNamespaces = true;
      };

      Install.WantedBy = [ "activitywatch.target" ];
    };

  # Most ActivityWatch client libraries has a function that loads with a
  # certain configuration format for all watchers and itself which is nice for
  # us.
  watcherSettingsFormat = pkgs.formats.toml { };

  # The module interface for the watchers.
  watcherType = { name, config, options, ... }: {
    options = {
      name = lib.mkOption {
        description = ''
          The name of the watcher. This will be used as the directory name for
          {file}`$XDG_CONFIG_HOME/activitywatch/$NAME` when
          {option}`services.activitywatch.watchers.<name>.settings` is set.
        '';
        type = lib.types.str;
        default = name;
        example = "aw-watcher-afk";
      };

      package = lib.mkOption {
        description = ''
          The derivation containing the watcher executable.
        '';
        type = lib.types.package;
        example = lib.literalExpression "pkgs.activitywatch";
      };

      executable = lib.mkOption {
        description = ''
          The name of the executable of the watcher. This is useful in case the
          watcher name is different from the executable. By default, this
          option uses the watcher name.
        '';
        type = lib.types.str;
        default = config.name;
      };

      settings = lib.mkOption {
        description = ''
          The settings for the individual watcher in TOML format. If set, a
          file will be generated at
          {file}`$XDG_CONFIG_HOME/activitywatch/$NAME/$FILENAME`.

          To set the basename of the settings file, see
          {option}`services.activitywatch.watchers.<name>.settingsFilename`.
        '';
        type = watcherSettingsFormat.type;
        default = { };
        example = lib.literalExpression ''
          {
            timeout = 300;
            poll_time = 2;
          }
        '';
      };

      settingsFilename = lib.mkOption {
        description = ''
          The filename of the generated settings file. By default, this uses
          the watcher name to be generated at
          {file}`$XDG_CONFIG_HOME/activitywatch/$NAME/$NAME.toml`.

          This is useful in case the watcher requires a different name for the
          configuration file.
        '';
        type = lib.types.str;
        default = "${config.name}.toml";
        example = "config.toml";
      };

      extraArgs = lib.mkOption {
        description = ''
          Extra arguments to be passed to the watcher executable.
        '';
        type = with lib.types; listOf str;
        default = [ ];
        defaultText = "[]";
        example = lib.literalExpression ''
          [
            "--host" "127.0.0.1"
          ]
        '';
      };
    };
  };

  generateWatchersConfig = name: cfg:
    let
      filename = "activitywatch/${cfg.name}/${cfg.settingsFilename}";
    in
    lib.nameValuePair filename (lib.mkIf (cfg.settings != { }) {
      source = watcherSettingsFormat.generate "activitywatch-watcher-${cfg.name}-settings" cfg.settings;
    });
in
{
  options.services.activitywatch = {
    enable = lib.mkEnableOption "ActivityWatch, an automated time tracker";

    package = lib.mkOption {
      description = ''
        Package containing the Rust implementation of ActivityWatch server.
      '';
      type = lib.types.package;
      default = pkgs.activitywatch;
      defaultText = "pkgs.activitywatch";
      example = lib.literalExpression "pkgs.aw-server-rust";
    };

    settings = lib.mkOption {
      description = ''
        Configuration for `aw-server-rust` to be generated at
        {file}`$XDG_CONFIG_HOME/activitywatch/aw-server-rust/config.toml`.
      '';
      type = watcherSettingsFormat.type;
      default = { };
      example = lib.literalExpression ''
        {
          port = 3012;

          custom_static = {
            my-custom-watcher = "''${pkgs.my-custom-watcher}/share/my-custom-watcher/static";
            aw-keywatcher = "''${pkgs.aw-keywatcher}/share/aw-keywatcher/static";
          };
        }
      '';
    };

    extraArgs = lib.mkOption {
      description = ''
        Additional arguments to be passed on to the ActivityWatch server.
      '';
      type = with lib.types; listOf str;
      default = [ ];
      defaultText = "[ ]";
      example = lib.literalExpression ''
        [
          "--port" "5999"
        ]
      '';
    };

    watchers = lib.mkOption {
      description = ''
        Watchers to be included with the service alongside with their
        configuration.

        If configuration is set, a file will be generated in
        {file}`$XDG_CONFIG_HOME/activitywatch/$WATCHER_NAME/$WATCHER_SETTINGS_FILENAME`.

        ::: {.note}
        The watchers are ran with the service manager and the settings format
        of the configuration is only assumed to be in TOML. Furthermore, it
        assumes the watcher program is using the official client libraries
        which has functions to store it in the appropriate location.
        :::
      '';
      type = with lib.types; attrsOf (submodule watcherType);
      default = { };
      defaultText = "{}";
      example = lib.literalExpression ''
        {
          aw-watcher-afk = {
            package = pkgs.activitywatch;
            settings = {
              timeout = 300;
              poll_time = 2;
            };
          };

          aw-watcher-windows = {
            package = pkgs.activitywatch;
            settings = {
              poll_time = 1;
              exclude_title = true;
            };
          };

          my-custom-watcher = {
            package = pkgs.my-custom-watcher;
            executable = "mcw";
            settings = {
              hello = "there";
              enable_greetings = true;
              poll_time = 5;
            };
            settingsFilename = "config.toml";
          };
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # We'll group these services with a target.
    systemd.user.targets.activitywatch = {
      Unit = {
        Description = "ActivityWatch server";
        Requires = [ "default.target" ];
        After = [ "default.target" ];
      };

      Install.WantedBy = [ "default.target" ];
    };

    systemd.user.services = lib.mapAttrs' mkWatcherService cfg.watchers // {
      activitywatch = {
        Unit = {
          Description = "ActivityWatch time tracker server";
          Documentation = [ "https://docs.activitywatch.net" ];
          BindsTo = [ "activitywatch.target" ];
        };

        Service = {
          ExecStart = "${cfg.package}/bin/aw-server ${lib.escapeShellArgs cfg.extraArgs}";
          Restart = "on-failure";

          # Some sandboxing.
          LockPersonality = true;
          NoNewPrivileges = true;
          RestrictNamespaces = true;
        };

        Install.WantedBy = [ "activitywatch.target" ];
      };
    };

    xdg.configFile = lib.mapAttrs' generateWatchersConfig cfg.watchers // {
      "activitywatch/aw-server-rust/config.toml" = lib.mkIf (cfg.settings != { }) {
        source = watcherSettingsFormat.generate "activitywatch-server-rust-config.toml" cfg.settings;
      };
    };
  };
}
