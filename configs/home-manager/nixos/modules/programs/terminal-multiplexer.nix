# Very useful for non-graphical installers.
{ config, lib, pkgs, ... }:

let
  userCfg = config.users.nixos;
  cfg = userCfg.programs.terminal-multiplexer;
in
{
  options.users.nixos.programs.terminal-multiplexer.enable =
    lib.mkEnableOption "terminal multiplexer";

  config = lib.mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      settings = {
        mouse_mode = false;
        copy_on_select = false;
        pane_frames = false;
      };
    };
  };
}
