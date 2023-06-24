{ config, options, lib, pkgs, ... }:

let
  cfg = config.programs.wezterm;

  shellIntegration = ''
    source ${pkgs.bash-preexec}/share/bash/bash-preexec.sh
    source ${cfg.package}/etc/profile.d/wezterm.sh
  '';
in
{
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
    programs.bash.interactiveShellInit = lib.mkIf config.programs.bash.enable shellIntegration;
    programs.zsh.interactiveShellInit = lib.mkIf config.programs.zsh.enable shellIntegration;
  };
}
