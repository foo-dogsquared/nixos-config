{
  description = "Specialized set of Nix modules for generating and applying themes.";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, ... }:
    let
      systems = inputs.flake-utils.lib.defaultSystems;
      sources = import ./npins;
    in inputs.flake-utils.lib.eachSystem systems
      (system: {
        devShells.default =
          import ./shell.nix { pkgs = import sources.nixos-stable { inherit system; }; };
      }) // import ./default.nix { };
}
