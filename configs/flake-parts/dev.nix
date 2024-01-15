# All of the development-related shtick for this project is over here.
{ inputs, ... }: {
  flake.lib = import ../../lib { lib = inputs.nixpkgs.lib; };

  perSystem = { config, lib, pkgs, ... }: {
    apps = {
      run-workflow-with-vm =
        let
          inputsArgs = lib.mapAttrsToList
            (name: source:
              let
                name' = if (name == "self") then "config" else name;
              in
              "'${name'}=${source}'")
            inputs;
          script = pkgs.callPackage ../../apps/run-workflow-with-vm {
            inputs = inputsArgs;
          };
        in
        {
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
      default = import ../../shell.nix { inherit pkgs; };
      docs = import ../../docs/shell.nix { inherit pkgs; };
    };
  };
}
