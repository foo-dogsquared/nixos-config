# Java is a rice variant, a coffee blend, an island, and a programming language.
# It sure is a flexible thing.
{ config, options, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.dev.java;
in {
  options.modules.dev.java = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    my.packages = with pkgs; [
      jdk # The Java Development Kit.
      jre # The Java Runtime Environment for running Java apps.
    ];
  };
}
