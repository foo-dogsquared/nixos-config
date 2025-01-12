{ config, lib, pkgs, ... }:

let
  cfg = config.programs.blender;

  addons =
    let
      blenderVersion = lib.versions.majorMinor cfg.package.version;
    in
    pkgs.symlinkJoin {
      name = "blender-${blenderVersion}-addons";
      paths = let
        _paths = cfg.addons ++ [ cfg.package ];
      in lib.concatMap (p: [ "${p}/share/blender" ]) _paths;
    };
in
{
  options.programs.blender = {
    enable = lib.mkEnableOption "Blender, a 3D computer graphics tool";

    package = lib.mkPackageOption pkgs "blender" {
      example = ''
        pkgs.blender-with-packages {
          name = "sample-studio-wrapped";
          packages = with pkgs.python3Packages; [ pandas ];
        }
      '';
    };

    addons = lib.mkOption {
      type = with lib.types; listOf package;
      description = ''
        List of packages providing Blender system resources at
        {file}`/share/blender` or at {file}`/share/blender/$MAJORMINORVERSION`.
      '';
      default = [ ];
      defaultText = "[]";
      example = lib.literalExpression ''
        with pkgs; [
          blender-addons-machin3tools
          blender-addons-glslTexture
        ]
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    # Modify the search path of the Blender addons. Since the default path is
    # on `/usr/share/blender/$MAJOR.$MINOR`, we'll have to modify it with an
    # environment variable. This means in a NixOS system, it is only expected
    # to have one instance of the system resources.
    environment.sessionVariables.BLENDER_SYSTEM_RESOURCES = lib.mkIf (builtins.length cfg.addons > 0) addons;
  };
}
