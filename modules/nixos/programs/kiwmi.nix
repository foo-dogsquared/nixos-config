{ config, lib, pkgs, ... }:

let
  cfg = config.programs.kiwmi;

  package = cfg.package.override { extraOptions = cfg.extraOptions; };
in
{
  options.programs.kiwmi = {
    enable = lib.mkEnableOption "Kiwmi, a fully programmable Wayland compositor";
    package = lib.mkOption {
      description = "The package containing the {command}`kiwmi` and {command}`kiwmic`.";
      type = lib.types.package;
      default = pkgs.kiwmi;
    };
    extraOptions = lib.mkOption {
      description = "Command line arguments passed to Kiwmi.";
      type = with lib.types; listOf str;
      default = [ ];
      defaultText = "[ ]";
      example = lib.literalExpression ''
        [ "-c" "./config/kiwmi/init.lua" ]
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ package ];
    services.xserver.displayManager.sessionPackages = [ package ];

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    };
  };
}
