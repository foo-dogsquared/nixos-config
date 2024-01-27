{ inputs, lib, ... }: {
  imports = [
    ./dev.nix
    ./packages.nix
    ./templates.nix

    # The environment configurations.
    ./home-manager.nix
    ./nixos.nix
    ./nixvim.nix
  ];

  _module.args = {
    # This will be shared among NixOS and home-manager configurations.
    defaultNixConf = { config, lib, pkgs, ... }: {
      # I want to capture the usual flakes to its exact version so we're
      # making them available to our system. This will also prevent the
      # annoying downloads since it always get the latest revision.
      nix.registry =
        lib.mapAttrs'
          (name: flake:
            let
              name' = if (name == "self") then "config" else name;
            in
            lib.nameValuePair name' { inherit flake; })
          inputs;

      nix.settings.nix-path =
        (lib.mapAttrsToList
          (name: source:
            let
              name' = if (name == "self") then "config" else name;
            in
            "${name'}=${source}")
          inputs
        ++ [
          "/nix/var/nix/profiles/per-user/root/channels"
        ]);

      # Extend nixpkgs with our overlays except for the NixOS-focused modules
      # here.
      nixpkgs.overlays = lib.attrValues inputs.self.overlays;
    };

    defaultOverlays = lib.attrValues inputs.self.overlays;
    defaultExtraArgs = {
      inherit (inputs) nix-colors;
    };
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
