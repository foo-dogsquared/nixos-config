{ inputs
, lib

, defaultExtraArgs
, defaultNixConf

, ...
}:

{
  setups.home-manager = {
    configs = {
      foo-dogsquared = {
        systems = [ "aarch64-linux" "x86_64-linux" ];
        overlays = [
          # Neovim nightly!
          inputs.neovim-nightly-overlay.overlays.default

          # Emacs unstable version!
          inputs.emacs-overlay.overlays.default

          # Helix master!
          inputs.helix-editor.overlays.default

          # Get all of the NUR.
          inputs.nur.overlay
        ];
        modules = [
          inputs.nix-colors.homeManagerModules.default
          inputs.nur.hmModules.nur
        ];
        deploy = {
          autoRollback = true;
          magicRollback = true;
        };
      };

      plover.systems = [ "x86_64-linux" ];
    };

    # This is to be used by the NixOS `home-manager.sharedModules` anyways.
    sharedModules = [
      # Import our own custom modules from here..
      ../../modules/home-manager
      ../../modules/home-manager/_private

      # ...plus a bunch of third-party modules.
      inputs.sops-nix.homeManagerModules.sops
      inputs.nix-index-database.hmModules.nix-index

      # The default shared config for our home-manager configurations. This
      # is also to be used for sharing modules among home-manager users from
      # NixOS configurations with `nixpkgs.useGlobalPkgs` set to `true` so
      # avoid setting nixpkgs-related options here.
      ({ pkgs, config, lib, ... }: {
        # Set some extra, yeah?
        _module.args = defaultExtraArgs;

        manual = lib.mkDefault {
          html.enable = true;
          json.enable = true;
          manpages.enable = true;
        };

        home.stateVersion = lib.mkDefault "23.11";
      })
    ];

    standaloneConfigModules = [
      defaultNixConf

      ({ config, lib, ... }: {
        # Don't create the user directories since they are assumed to
        # be already created by a pre-installed system (which should
        # already handle them).
        xdg.userDirs.createDirectories = lib.mkForce false;

        programs.home-manager.enable = lib.mkForce true;
        targets.genericLinux.enable = lib.mkDefault true;
      })
    ];
  };

  flake = {
    # Extending home-manager with my custom modules, if anyone cares.
    homeModules.default = ../../modules/home-manager;
  };
}
