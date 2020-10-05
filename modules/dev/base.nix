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
      caddy             # THE ULTIMATE HTTPS/2 SERVER FOR 'YER GOLFIN' SESSIONS!!!
      cmake             # Yo, I heard you like Makefiles.
      cookiecutter      # A project scaffolding tool.
      gnumake           # Make your life easier with GNU Make.
      hyperfine         # You shouldn't be feel just fine with your programs...
      nixfmt            # Formatter for uniform Nix code.
      stow              # Build your symlink farm on the other side of the country, er, filesystem.
      tldr              # What manuals should include.
      universal-ctags   # Enable fast traveling to your code (assuming written in a supported language).
    ];

    # Augment your shell with automatic environment variables loading and unloading.
    my.home.programs = {
      direnv.enable = true;
      fish.enable = true;
    };
  };
}
