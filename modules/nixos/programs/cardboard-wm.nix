{ config, options, lib, pkgs, ... }:

let
  cfg = config.programs.cardboard-wm;

  cardboardPackage = cfg.package.overrideAttrs (super: rec {
    passthru.providedSessions = [ "cardboard" ];
  });
in
{
  options.programs.cardboard-wm = {
    enable =
      lib.mkEnableOption "Cardboard, a scrollable tiling Wayland compositor";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.cardboard;
      defaultText = lib.literalExpression "pkgs.cardboard";
      description = ''
        The derivation containing the {command}`cardboard` and
        {command}`cutter` binary.
      '';
    };

    extraOptions = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      description = "Command-line arguments to be passed to Cardboard.";
    };

    extraPackages = lib.mkOption {
      type = with lib.types; listOf package;
      default = [ ];
      description = ''
        Extra packages to be installed with this program.
      '';
      example = lib.literalExpression ''
        with pkgs; [
          waybar
          eww
        ]
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cardboardPackage ] ++ cfg.extraPackages;
    security.polkit.enable = true;
    services.xserver.displayManager.sessionPackages = [ cardboardPackage ];
    hardware.opengl.enable = true;
    programs.xwayland.enable = true;
    programs.dconf.enable = true;
    fonts.enableDefaultFonts = true;
    xdg.portal.wlr.enable = true;
  };
}
