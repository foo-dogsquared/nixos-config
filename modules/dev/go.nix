# Go, go, Golang coders!
{ config, options, lib, pkgs, ... }:

with lib;
{
  options.modules.dev.go = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.dev.go.enable {
    my.packages = with pkgs; [
      delve     # Wait, Go doesn't have a proper debugger?
      go        # The other zoomer proglang (READ: proglang is a zoomer term for programming language).
    ];
  };
}
