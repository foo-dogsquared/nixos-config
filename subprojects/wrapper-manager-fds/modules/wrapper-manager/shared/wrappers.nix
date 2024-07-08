{ name, lib, config, pkgs, envConfig, ... }:

let
  flagType = with lib.types; listOf (coercedTo anything (x: builtins.toString x) str);
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
      type = with lib.types; attrsOf str;
      description = ''
        A set of environment variables to be declared in the wrapper script.
      '';
      default = { };
      example = {
        "FOO_TYPE" = "custom";
        "FOO_LOG_STYLE" = "systemd";
      };
    };

    unset = lib.mkOption {
      type = with lib.types; listOf nonEmptyStr;
      description = ''
        A list of environment variables to be unset into the wrapper script.
      '';
      default = [ ];
      example = [ "NO_COLOR" ];
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
        Script fragments to run before the main executable. This option is only
        used when the wrapper script is not compiled into a binary (that is,
        when {option}`build.isBinary` is set to `false`).
      '';
      default = "";
      example = lib.literalExpression ''
        echo "HELLO WORLD!"
      '';
    };

    makeWrapperArgs = lib.mkOption {
      type = with lib.types; listOf str;
      description = ''
        A list of extra arguments to be passed as part of makeWrapper.
      '';
      example = [ "--inherit-argv0" ];
      readOnly = true;
    };
  };

  config = {
    makeWrapperArgs = [
      "--argv0" config.arg0
    ]
    ++ (lib.mapAttrsToList (n: v: "--set ${n} ${v}") config.env)
    ++ (builtins.map (v: "--unset ${v}") config.unset)
    ++ (builtins.map (v: "--prefix 'PATH' ':' ${lib.escapeShellArg v}") config.pathAdd)
    ++ (builtins.map (v: "--add-flags ${v}") config.prependArgs)
    ++ (builtins.map (v: "--append-flags ${v}") config.appendArgs)
    ++ (lib.optionals (!envConfig.build.isBinary && config.preScript != "") (
      let
        preScript =
          pkgs.runCommand "wrapper-script-prescript-${config.executableName}" { } config.preScript;
      in
        [ "--run" preScript ]));
  };
}
