# Java is a rice variant, a coffee blend, an island, and a programming language.
# It sure is a flexible thing.
{ config, options, lib, pkgs, ... }:

with lib;
{
  options.modules.dev.java = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.dev.java.enable {
    home.packages = [
      jdk       # The Java Development Kit.
      jre       # The Java Runtime Environment for running Java apps.
    ];
  };
}
