# Another language for portable shell scripting.
# This installs Python 3 with my usual packages.
# For projects with other libraries (e.g., Django, Pytorch), you can just have a `default.nix` (and a `shell.nix` for more convenience).
{ config, options, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.dev.python;
in {
  options.modules.dev.python = let
    mkBoolOption = bool: mkOption {
      type = types.bool;
      default = bool;
    }; in {
      enable = mkBoolOption false;
      math.enable = mkBoolOption false;
  };

  config = mkIf cfg.enable {
    my.packages = with pkgs; [
      (python37.withPackages (p: with python3Packages; [
        beautifulsoup4            # How soups are beautiful again?
        requests                  # The requests for your often-asked questions.
        pytools                   # It's the little things that counts.
        pytest                    # Try to make a good grade or else.
        poetry                    # It rhymes...
        scrapy                    # Create an extractor from a box of scraps.
        setuptools                # Setup your stuff.
      ]

      ++ (if cfg.math.enable then [
        numpy                     # Numbers are also good, right?
        sympy                     # When will you notice that math is good?
      ] else [])))
    ];
  };
}

