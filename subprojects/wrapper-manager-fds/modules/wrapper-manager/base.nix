{
  config,
  lib,
  options,
  ...
}:

let
  envConfig = config;

  toStringType = with lib.types; coercedTo (oneOf [str path int float bool]) (x: "${x}") str;
  envSubmodule =
    {
      config,
      lib,
      name,
      ...
    }:
    {
      options = {
        action = lib.mkOption {
          type = lib.types.enum [
            "unset"
            "set"
            "set-default"
            "prefix"
            "suffix"
          ];
          description = ''
            Sets the appropriate action for the environment variable.

            * `unset`... unsets the given variable.
            * `set-default` only sets the variable with the given value if
            not already set.
            * `set` forcibly sets the variable with given value.
          '';
          default = "set";
          example = "unset";
        };

        value = lib.mkOption {
          type = with lib.types; either toStringType (listOf toStringType);
          description = ''
            The value of the variable that is holding.

            ::: {.note}
            It accepts a list of values only for `prefix` and `suffix` action.
            :::
          '';
          example = "HELLO THERE";
        };

        separator = lib.mkOption {
          type = lib.types.str;
          description = ''
            Separator used to create a character-delimited list of the
            environment variable holding a list of values.

            ::: {.note}
            Only used for `prefix` and `suffix` action.
            :::
          '';
          default = ":";
          example = ";";
        };
      };
    };

  wrapperType =
    {
      name,
      lib,
      config,
      pkgs,
      ...
    }:
    let
      flagType = with lib.types; listOf toStringType;
    in
    {
      options = {
        prependArgs = lib.mkOption {
          type = flagType;
          description = ''
            A list of arguments to be prepended to the user-given argument for the
            wrapper script.
          '';
          default = [ ];
          example = lib.literalExpression ''
            [
              "--config" ./config.conf
            ]
          '';
        };

        appendArgs = lib.mkOption {
          type = flagType;
          description = ''
            A list of arguments to be appended to the user-given argument for the
            wrapper script.
          '';
          default = [ ];
          example = lib.literalExpression ''
            [
              "--name" "doggo"
              "--location" "Your mom's home"
            ]
          '';
        };

        arg0 = lib.mkOption {
          type = lib.types.str;
          description = ''
            The first argument of the wrapper script.
          '';
          example = lib.literalExpression "lib.getExe' pkgs.neofetch \"neofetch\"";
        };

        executableName = lib.mkOption {
          type = lib.types.nonEmptyStr;
          description = "The name of the executable.";
          default = name;
          example = "custom-name";
        };

        env = options.environment.variables;
        pathAdd = options.environment.pathAdd;

        preScript = lib.mkOption {
          type = lib.types.lines;
          description = ''
            Script fragments to run before the main executable.

            ::: {.note}
            This option is only used when {option}`build.isBinary` is set to
            `false`.
            :::
          '';
          default = "";
          example = lib.literalExpression ''
            echo "HELLO WORLD!"
          '';
        };

        makeWrapperArgs = lib.mkOption {
          type = with lib.types; listOf str;
          description = ''
            A list of extra arguments to be passed as part of `makeWrapper`
            build step.
          '';
          example = [ "--inherit-argv0" ];
        };
      };

      config = lib.mkMerge [
        {
          env = envConfig.environment.variables;
          pathAdd = envConfig.environment.pathAdd;

          makeWrapperArgs =
            lib.mapAttrsToList (
              n: v:
              if v.action == "unset" then
                "--${v.action} ${lib.escapeShellArg n}"
              else if lib.elem v.action [ "prefix" "suffix" ] then
                "--${v.action} ${lib.escapeShellArg n} ${lib.escapeShellArg v.separator} ${lib.escapeShellArg (lib.concatStringsSep v.separator v.value)}"
              else
                "--${v.action} ${lib.escapeShellArg n} ${lib.escapeShellArg v.value}"
            ) config.env
            ++ (builtins.map (v: "--add-flags ${lib.escapeShellArg v}") config.prependArgs)
            ++ (builtins.map (v: "--append-flags ${lib.escapeShellArg v}") config.appendArgs)
            ++ (lib.optionals (!envConfig.build.isBinary && config.preScript != "") (
              let
                preScript =
                  pkgs.runCommand "wrapper-script-prescript-${config.executableName}" { }
                    config.preScript;
              in
              [
                "--run"
                preScript
              ]
            ))
            ++ [ "--inherit-argv0" ];
        }

        (lib.mkIf (config.pathAdd != [ ]) {
          env.PATH.value = lib.lists.map builtins.toString config.pathAdd;
          env.PATH.action = "prefix";
        })
      ];
    };
in
{
  options = {
    wrappers = lib.mkOption {
      type = with lib.types; attrsOf (submodule wrapperType);
      description = ''
        A set of wrappers to be included in the resulting derivation from
        wrapper-manager evaluation.
      '';
      default = { };
      example = lib.literalExpression ''
        {
          yt-dlp-audio = {
            arg0 = lib.getExe' pkgs.yt-dlp "yt-dlp";
            prependArgs = [
              "--config-location" ./config/yt-dlp/audio.conf
            ];
          };
        }
      '';
    };

    basePackages = lib.mkOption {
      type = with lib.types; either package (listOf package);
      description = ''
        Packages to be included in the wrapper package. However, there are
        differences in behavior when given certain values.

        * When the value is a bare package, the build process will use
        `$PACKAGE.overrideAttrs` to create the package. This makes it suitable
        to be used as part of `programs.<name>.package` typically found on
        other environments (e.g., NixOS).

        * When the value is a list of packages, the build process will use
        `symlinkJoin` as the builder to create the derivation.
      '';
      default = [ ];
      example = lib.literalExpression ''
        with pkgs; [
          yt-dlp
        ]
      '';
    };

    environment.variables = lib.mkOption {
      type = with lib.types; attrsOf (submodule envSubmodule);
      description = ''
        A global set of environment variables and their actions to be applied
        per-wrapper.
      '';
      default = { };
      example = {
        "FOO_TYPE".value = "custom";
        "FOO_LOG_STYLE" = {
          action = "set-default";
          value = "systemd";
        };
        "USELESS_VAR".action = "unset";
      };
    };

    environment.pathAdd = lib.mkOption {
      type = with lib.types; listOf path;
      description = ''
        A global list of paths to be added per-wrapper as part of the `PATH`
        environment variable.
      '';
      default = [ ];
      example = lib.literalExpression ''
        wrapperManagerLib.getBin (with pkgs; [
          yt-dlp
          gallery-dl
        ])
      '';
    };
  };
}
