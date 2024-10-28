# All of the development-related shtick for this project is over here.
{ inputs, ... }: {
  flake = {
    lib = import ../../lib { lib = inputs.nixpkgs.lib; };

    foodogsquaredLib = ../../lib;
  };

  perSystem = { config, lib, pkgs, ... }: {
    apps = {
      run-workflow-with-vm = let
        inputsArgs = lib.mapAttrsToList (name: source:
          let name' = if (name == "self") then "config" else name;
          in "'${name'}=${source}'") inputs;
        script = pkgs.callPackage ../../apps/run-workflow-with-vm {
          inputs = inputsArgs;
        };
      in {
        type = "app";
        program = "${script}/bin/run-workflow-with-vm";
      };
    };

    # No amount of formatters will make this codebase nicer but it sure does
    # feel like it does.
    formatter = pkgs.treefmt;

    # My several development shells for usual type of projects. This is much
    # more preferable than installing all of the packages at the system
    # configuration (or even home environment).
    devShells = import ../../shells { inherit pkgs; } // {
      default = import ../../shell.nix {
        inherit pkgs;
        extraPackages = with pkgs;
          [
            # Mozilla addons-specific tooling. Unfortunately, only available with
            # flakes-based setups.
            nur.repos.rycee.mozilla-addons-to-nix
          ];
      };
      website = import ../../docs/website/shell.nix { inherit pkgs; };
    };

    # Packages that are meant to be consumed inside of a development
    # environment.
    devPackages = { inherit (import ../../docs { inherit pkgs; }) website; };

    # All of the typical devcontainers to be used.
    devContainers = import ../../devcontainers { inherit pkgs; };
  };
}
