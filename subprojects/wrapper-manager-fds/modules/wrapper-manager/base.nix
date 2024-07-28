{ config, lib, ... }:

let
  envConfig = config;

  wrapperType = { name, lib, config, pkgs, ... }:
    let
      toStringType = with lib.types; coercedTo anything (x: builtins.toString x) str;
      flagType = with lib.types; listOf toStringType;

      envSubmodule = { config, lib, name, ... }: {
        options = {
          action = lib.mkOption {
            type = lib.types.enum [ "unset" "set" "set-default" ];
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
            type = toStringType;
            description = ''
              The value of the variable that is holding.
            '';
            example = "HELLO THERE";
          };

          isEscaped = lib.mkEnableOption "escaping of the value" // {
            default = true;
          };
        };
      };
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
            The first argument of the wrapper script. This option is used when the
            {option}`build.variant` is `executable`.
          '';
          example = lib.literalExpression "lib.getExe' pkgs.neofetch \"neofetch\"";
        };

        executableName = lib.mkOption {
          type = lib.types.nonEmptyStr;
          description = "The name of the executable.";
          default = name;
          example = "custom-name";
        };

        env = lib.mkOption {
          type = with lib.types; attrsOf (submodule envSubmodule);
          description = ''
            A set of environment variables to be declared in the wrapper
            script.
          '';
          default = { };
          example = {
            "FOO_TYPE" = "custom";
            "FOO_LOG_STYLE" = "systemd";
          };
        };

        pathAdd = lib.mkOption {
          type = with lib.types; listOf path;
          description = ''
            A list of paths to be added as part of the `PATH` environment variable.
          '';
          default = [ ];
          example = lib.literalExpression ''
            wrapperManagerLib.getBin (with pkgs; [
              yt-dlp
              gallery-dl
            ])
          '';
        };

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
          makeWrapperArgs = [
            "--argv0" config.arg0
          ]
          ++ (lib.mapAttrsToList
              (n: v:
                if v.action == "unset"
                then "--${v.action} ${lib.escapeShellArg n}"
                else "--${v.action} ${lib.escapeShellArg n} ${if v.isEscaped then lib.escapeShellArg v.value else v.value}")
              config.env)
          ++ (builtins.map (v: "--add-flags ${lib.escapeShellArg v}") config.prependArgs)
          ++ (builtins.map (v: "--append-flags ${lib.escapeShellArg v}") config.appendArgs)
          ++ (lib.optionals (!envConfig.build.isBinary && config.preScript != "") (
            let
              preScript =
                pkgs.runCommand "wrapper-script-prescript-${config.executableName}" { } config.preScript;
            in
              [ "--run" preScript ]));
        }

        (lib.mkIf (config.pathAdd != [ ]) {
          env.PATH.value = lib.concatStringsSep ":" config.pathAdd;

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
      type = with lib.types; listOf package;
      description = ''
        A list of packages to be included in the wrapper package.

        ::: {.note}
        This can override some of the binaries included in this list which is
        typically intended to be used as a wrapped package.
        :::
      '';
      default = [ ];
      example = lib.literalExpression ''
        with pkgs; [
          yt-dlp
        ]
      '';
    };
  };
}
