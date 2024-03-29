{ inputs, lib, ... }: {
  imports = [
    ./dev.nix
    ./packages.nix
    ./templates.nix

    # The environment configurations.
    ./disko.nix
    ./home-manager.nix
    ./nixos.nix
    ./nixvim.nix

    # Subprojects.
    ./bahaghari.nix
  ];

  _module.args = {
    # This will be shared among NixOS and home-manager configurations.
    defaultNixConf = { config, lib, pkgs, ... }: {
      # Extend nixpkgs with our overlays except for the NixOS-focused modules
      # here.
      nixpkgs.overlays = lib.attrValues inputs.self.overlays;
    };

    defaultOverlays = lib.attrValues inputs.self.overlays;
  };

  perSystem = { lib, system, ... }: {
    _module.args = {
      # nixpkgs for this module should be used as less as possible especially
      # for building NixOS and home-manager systems.
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = lib.attrValues inputs.self.overlays ++ [
          inputs.nur.overlay
        ];
      };
    };
  };
}
