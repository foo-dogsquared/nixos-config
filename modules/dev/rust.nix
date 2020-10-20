# Ah yes, Rust...
# The programming language that made me appreciate/tolerate C++ even more.
{ config, options, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.dev.rust;
in
{
  options.modules.dev.rust = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    my.packages = with pkgs; [
      rustup
    ];

    my.env = {
      CARGO_HOME = "$XDG_DATA_HOME/cargo";
      RUSTUP_HOME = "$XDG_DATA_HOME/rustup";
      PATH = [ "$CARGO_HOME/bin" ];
    };
  };
}
