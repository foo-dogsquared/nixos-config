{ config, lib, pkgs, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.programs.terminal-multiplexer;
in
{
  options.users.foo-dogsquared.programs.terminal-multiplexer.enable =
    lib.mkEnableOption "foo-dogsquared's terminal multiplexer setup";

  config = lib.mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      settings = {
        mouse_mode = false;
        copy_on_select = false;
        pane_frames = false;
        default_layout = "editor";
        layout_dir = builtins.toString ../../config/zellij/layouts;
      };
    };
  };
}
