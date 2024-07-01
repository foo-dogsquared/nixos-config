{ config, lib, ... }:

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

    package = lib.mkOption {
      type = lib.types.package;
      description = ''
        The package to be wrapped. This is used only when the
        {option}`build.variant` is set to `package.`
      '';
      example = lib.literalExpression "pkgs.hello";
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

    executableName = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = ''
        The name of the executable of the wrapper script.

        This option behaves differently depending on {option}`build.variant`.

        - When the build variant option is `executable`, it sets the name of the
        wrapper script.
        - When the build variant option is `package`, it depends on the name on
        one of the executables from the given package.
      '';
      default =
        if config.build.variant == "executable" then
          lib.tail (lib.path.subpath.components config.arg0)
        else
          config.package.meta.mainProgram or config.package.pname;
      example = "custom-name";
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
        Script to run before the main executable.
      '';
      default = "";
      example = lib.literalExpression ''
        echo "HELLO WORLD!"
      '';
    };
  };
}
