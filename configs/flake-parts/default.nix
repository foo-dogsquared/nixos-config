{ inputs, config, lib, ... }: {
  imports = [
    ./dev.nix
    ./packages.nix
    ./templates.nix

    # Environment configurations.
    ./disko.nix
    ./home-manager.nix
    ./nixos.nix
    ./nixvim.nix
    ./wrapper-manager.nix

    # Subprojects.
    ./bahaghari.nix
    ./wrapper-manager-fds.nix
  ];

  _module.args = {
    # This will be shared among NixOS and home-manager configurations.
    defaultNixConf = { config, lib, pkgs, ... }: {
      # Extend nixpkgs with our overlays except for the NixOS-focused modules
      # here.
      nixpkgs.overlays = lib.attrValues inputs.self.overlays;
    };

    defaultOverlays = lib.attrValues inputs.self.overlays;

    defaultSystems = [ "x86_64-linux" ];
  };

  setups.sharedNixpkgsConfig = {
    allowUnfree = true;
  };

  perSystem = { lib, system, ... }: {
    _module.args = {
      # nixpkgs for this module should be used as less as possible especially
      # for building NixOS and home-manager systems.
      pkgs = import inputs.nixpkgs {
        inherit system;
        config = config.setups.sharedNixpkgsConfig;
        overlays = lib.attrValues inputs.self.overlays ++ [
          inputs.nur.overlay
        ];
      };
    };
  };
}
