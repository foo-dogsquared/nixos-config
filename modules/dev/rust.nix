# Ah yes, Rust...
# The programming language that made me appreciate/tolerate C++ even more.
{ config, options, lib, pkgs, ... }:

with lib;
{
  options.modules.dev.rust = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.dev.rust.enable {
    home.packages = with pkgs; [
      rustup
    ];

    programs.zsh.sessionVariables = mkIf config.modules.shell.zsh.enable {
      CARGO_HOME = "${config.xdg.dataHome}/cargo";
      RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
      PATH = [ "$CARGO_HOME/bin" ];
    };
  };
}
