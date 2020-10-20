# Go, go, Golang coders!
{ config, options, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.dev.go;
in
{
  options.modules.dev.go = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    my.packages = with pkgs; [
      delve     # Wait, Go doesn't have a proper debugger?
      go        # The other zoomer proglang (READ: proglang is a zoomer term for programming language).
    ];
  };
}
