{ config, lib, pkgs, ... }:

{
  options.build = {
    isBinary = lib.mkOption {
      type = lib.types.bool;
      description = ''
        Sets the build step to create a tiny compiled executable for the
        wrapper. By default, it is set to `true`.
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
          mkWrapBuild = wrappers:
            lib.concatMapStrings (v: ''
              makeWrapper "${v.arg0}" "${builtins.placeholder "out"}/bin/${v.executableName}" ${lib.concatStringsSep " " v.makeWrapperArgs}
            '') wrappers;

          mkDesktopEntries = desktopEntries:
            builtins.map (entry: pkgs.makeDesktopItem entry) desktopEntries;
        in
          pkgs.symlinkJoin {
            name = "wrapper-manager-fds-wrapped-package";
            paths = config.basePackages;
            nativeBuildInputs =
              if config.build.isBinary
              then [ pkgs.makeBinaryWrapper ]
              else [ pkgs.makeWrapper ]
              ++ lib.optionals (pkgs.stdenv.isLinux && config.xdg.desktopEntries != { }) [ pkgs.copyDesktopItems ];
            postBuild = ''
              ${config.build.extraSetup}
              ${mkWrapBuild (lib.attrValues config.wrappers)}
            '';
            desktopItems =
              mkDesktopEntries (lib.attrValues config.xdg.desktopEntries);
          };
    };
  };
}
