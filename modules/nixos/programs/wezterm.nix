{ config, options, lib, pkgs, ... }:

let
  cfg = config.programs.wezterm;
in {
  options.programs.wezterm = {
    enable = lib.mkEnableOption "Wezterm terminal emulator";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.wezterm;
      description = "Package containing <command>wezterm</command> binary.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    # This is needed for shell integration and applying semantic zones.
    environment.interactiveShellInit = ''
      . ${cfg.package}/etc/profiles.d/wezterm.sh
    '';
  };
}
