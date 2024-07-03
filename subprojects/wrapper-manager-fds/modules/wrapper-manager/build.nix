{ config, lib, pkgs, wrapperManagerLib, ... }:

{
  options.build = {
    variant = lib.mkOption {
      type = lib.types.enum [ "executable" "package" ];
      description = ''
        Tells how should wrapper-manager wrap the executable. The toplevel
        derivation resulting from the module environment will vary depending on
        the value.

        - With `executable`, the wrapper is a lone executable wrapper script in
        `$OUT/bin` subdirectory in the output.

        - With `package`, wrapper-manager creates a wrapped package with all of
        the output contents intact.
      '';
      default = "executable";
      example = "package";
    };

    isBinary = lib.mkOption {
      type = lib.types.bool;
      description = ''
        Sets the build step to create a tiny compiled executable for the
        wrapper. By default, it is set to `true`.
      '';
      default = true;
      example = false;
    };

    makeWrapperArgs = lib.mkOption {
      type = with lib.types; listOf str;
      description = ''
        A list of extra arguments to be passed to the `makeWrapperArgs` build
        step of the evaluation.
      '';
      example = [ "--inherit-argv0" ];
    };

    extraArgs = lib.mkOption {
      type = with lib.types; attrsOf anything;
      description = ''
        A attrset of extra arguments to be passed to the
        `wrapperManagerLib.mkWrapper` function. This will also be passed as
        part of the derivation attribute into the resulting script from
        {option}`preScript`.
      '';
      default = { };
    };

    toplevel = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      internal = true;
      description = "A derivation containing the wrapper script.";
    };
  };

  config = {
    build = {
      makeWrapperArgs = [
        "--argv0" (config.executableName or config.arg0)
      ]
      ++ (lib.mapAttrsToList (n: v: "--set ${n} ${v}") config.env)
      ++ (builtins.map (v: "--unset ${v}") config.unset)
      ++ (builtins.map (v: "--prefix 'PATH' ':' ${lib.escapeShellArg v}") config.pathAdd)
      ++ (builtins.map (v: "--add-flags ${v}") config.prependArgs)
      ++ (builtins.map (v: "--append-flags ${v}") config.appendArgs)
      ++ (lib.optionals (!config.build.isBinary && config.preScript != "") (
        let
          preScript =
            pkgs.runCommand "wrapper-script-prescript-${config.executableName}" config.build.extraArgs config.preScript;
        in
          [ "--run" preScript ]));

        toplevel =
          if config.build.variant == "executable" then
            wrapperManagerLib.mkWrapper (config.build.extraArgs // {
              inherit (config) arg0 executableName;
              inherit (config.build) isBinary makeWrapperArgs;
            })
          else
            wrapperManagerLib.mkWrappedPackage (config.build.extraArgs // {
              inherit (config) arg0 package executableName;
              inherit (config.build) isBinary makeWrapperArgs;
            });
    };
  };
}
