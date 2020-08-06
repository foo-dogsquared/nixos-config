# The utmost requirements for a development workflow.
{ config, options, lib, pkgs, ... }:

with lib;
{
  options.modules.dev.base = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.dev.base.enable {
    home.packages = with pkgs; [
      cookiecutter      # A project scaffolding tool.
      gnumake           # Make your life easier with GNU Make.
      universal-ctags   # Enable fast traveling to your code (assuming written in a supported language).
    ];
  };
}
