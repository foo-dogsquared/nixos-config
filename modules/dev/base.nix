# The utmost requirements for a development workflow.
{ config, options, lib, pkgs, ... }:

with lib;

let cfg = config.modules.dev.base;
in {
  options.modules.dev.base = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    my.packages = with pkgs; [
      caddy # THE ULTIMATE HTTPS/2 SERVER FOR 'YER GOLFIN' SESSIONS!!!
      cmake # Yo, I heard you like Makefiles.
      cookiecutter # A project scaffolding tool.
      gnumake # Make your life easier with GNU Make.
      gitAndTools.hub # I wish Gitlab has something called lab.
      hyperfine # You shouldn't be feel just fine with your programs...
      kmon # A Linux kernel monitoring tool, right...
      nixfmt # Formatter for uniform Nix code.
      radare2-cutter # Rev-eng tools to feel like a hacker.
      stow # Build your symlink farm on the other side of the country, er, filesystem.
      tealdeer # What manuals should include.
      universal-ctags # Enable fast traveling to your code (assuming written in a supported language).
    ];

    # Augment your shell with automatic environment variables loading and unloading.
    my.home.programs = {
      direnv = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
      };

      # Enabling all of the shells for cross-testing purposes.
      fish.enable = true;
      bash.enable = true;
      zsh.enable = true;
    };
  };
}
