{ config, options, lib, pkgs, ... }:

let
  cfg = config.programs.blender;

  addons = pkgs.symlinkJoin {
    name = "blender-${lib.majorMinor cfg.package.version}-addons";
    paths = builtins.map (p: "${p}/share/blender") cfg.addons;
  };
in
{
  options.programs.blender = {
    enable = lib.mkEnableOption "Blender, a 3D computer graphics tool";

    package = lib.mkPackageOption pkgs "blender" {
      example = ''
        pkgs.blender-with-packages {
          name = "sample-studio-wrapped";
          packages = with pkgs.pythonPackages; [ pandas ];
        }
      '';
    };

    addons = lib.mkOption {
      type = with lib.types; listOf package;
      description = lib.mdDoc ''
        List of packages to be added to Blender system resources. The addon
        packages are expected to be in {file}`$out/share/blender`.
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

  cfg = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    # Modify the search path of the Blender addons. Since the default path is
    # on `/usr/share/blender/$MAJOR.$MINOR`, we'll have to modify it with an
    # environment variable. This means in a NixOS system, it is only expected
    # to have one instance of the system resources.
    environment.sessionVariables.BLENDER_SYSTEM_RESOURCES = lib.mkIf (builtins.length cfg.addons > 0) "/etc/blender";

    # It is acceptable to have this as a read-only directory, right?
    environment.etc.blender.source = addons;
  };
}
