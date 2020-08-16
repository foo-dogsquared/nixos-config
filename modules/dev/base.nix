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
    my.packages = with pkgs; [
      caddy2            # THE ULTIMATE HTTPS/2 SERVER FOR 'YER GOLFIN' SESSIONS!!!
      cookiecutter      # A project scaffolding tool.
      direnv            # Augment your shell with automatic environment variables loading and unloading.
      gnumake           # Make your life easier with GNU Make.
      tldr		# What manuals should include.
      universal-ctags   # Enable fast traveling to your code (assuming written in a supported language).
    ];
  };
}
