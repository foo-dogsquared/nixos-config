{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.build = {
    isBinary = lib.mkOption {
      type = lib.types.bool;
      description = ''
        Sets the build step to create a tiny compiled executable for the
        wrapper. By default, it is set to `true`.

        ::: {.warning}
        Binary wrappers cannot have runtime expansion in its arguments
        especially when setting environment variables that needs it. For this,
        you'll have to switch to shell wrappers (e.g., `build.isBinary =
        false`).
        :::
      '';
      default = true;
      example = false;
    };

    extraSetup = lib.mkOption {
      type = lib.types.lines;
      description = ''
        Additional script for setting up the wrapper script derivation.
      '';
      default = "";
    };

    extraPassthru = lib.mkOption {
      type = with lib.types; attrsOf anything;
      description = ''
        Set of data to be passed through `passthru` of the resulting
        derivation.
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
      toplevel =
        let
          mkWrapBuild =
            wrappers:
            lib.concatMapStrings (v: ''
              makeWrapper "${v.arg0}" "${builtins.placeholder "out"}/bin/${v.executableName}" ${lib.concatStringsSep " " v.makeWrapperArgs}
            '') wrappers;

          mkDesktopEntries = desktopEntries: builtins.map (entry: pkgs.makeDesktopItem entry) desktopEntries;

          desktopEntries = mkDesktopEntries (lib.attrValues config.xdg.desktopEntries);
        in
          if lib.isList config.basePackages then
            pkgs.symlinkJoin {
              passthru = config.build.extraPassthru;
              name = "wrapper-manager-fds-wrapped-package";
              paths = desktopEntries ++ config.basePackages;
              nativeBuildInputs =
                if config.build.isBinary then [ pkgs.makeBinaryWrapper ] else [ pkgs.makeWrapper ];
              postBuild = ''
                ${config.build.extraSetup}
                ${mkWrapBuild (lib.attrValues config.wrappers)}
              '';
            }
          else
            config.basePackages.overrideAttrs (final: prev: {
              nativeBuildInputs =
                (prev.nativeBuildInputs or [ ])
                ++ (if config.build.isBinary then [ pkgs.makeBinaryWrapper ] else [ pkgs.makeWrapper ])
                ++ lib.optionals (config.xdg.desktopEntries != { }) [ pkgs.copyDesktopItems ];
              desktopItems = (prev.desktopItems or [ ]) ++ desktopEntries;
              postFixup = ''
                ${prev.postFixup or ""}
                ${mkWrapBuild (lib.attrValues config.wrappers)}
              '';
              passthru = lib.recursiveUpdate (prev.passthru or { }) (config.build.extraPassthru // {
                unwrapped = config.basePackages;
              });
            });
    };
  };
}
