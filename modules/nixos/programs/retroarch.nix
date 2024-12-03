{ config, lib, pkgs, ... }:

let
  cfg = config.programs.retroarch;

  finalPkg = pkgs.wrapRetroArch {
    inherit (cfg) cores settings;
  };
in
{
  options.programs.retroarch = {
    enable = lib.mkEnableOption "configuring Retroarch";

    cores = lib.mkOption {
      type = with lib.types; listOf package;
      default = [ ];
      description = ''
        List of Retroarch cores to be included with the package.
      '';
      example = lib.literalExpression ''
        with pkgs.libretro; [
          ppsspp
          desmume
          pcsx2
        ]
      '';
    };

    settings = lib.mkOption {
      type = with lib.types; attrsOf anything;
      default = { };
      description = ''
        Additional settings to be configured with the Retroarch nixpkgs
        wrapper.
      '';
      example = lib.literalExpression ''
        {
          assets_directory = "''${pkgs.retroarch-assets}/share/retroarch-assets";
          joypad_autoconfig_dir = "''${pkgs.retroarch-joypad-autoconfig}/share/libretro/autoconfig";
          libretro_info_path = "''${pkgs.libretro-core-info}/share/retroarch/cores";
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ finalPkg ];
  };
}
