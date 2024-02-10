{ lib, inputs, ... }: {
  flake = {
    nixosModules.default = ../modules;
  };

  perSystem = { lib, pkgs, system, ... }: {
    formatter = pkgs.treefmt;

    devShells.default = import ../../shell.nix { inherit pkgs; };

    # Just make sure it actually compiles with a very minimal NixOS
    # configuration.
    checks.nixos-module-test =
      let
        nixosSystem = args:
          import "${inputs.nixpkgs}/nixos/lib/eval-config.nix" args;
      in
      nixosSystem {
        modules = [
          ({ modulesPath, ... }: {
            imports = [
              "${modulesPath}/profiles/minimal.nix"
            ];

            nixpkgs.hostPlatform = system;
            boot.loader.grub.enable = false;
            fileSystems."/".device = "nodev";
          })
        ];
      };
  };
}
