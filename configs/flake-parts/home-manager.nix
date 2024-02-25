{ inputs
, lib

, defaultNixConf

, ...
}:

{
  setups.home-manager = {
    configs = {
      # The typical user in desktop environments.
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
          inputs.nur.hmModules.nur
        ];
        nixvim.instance = "fiesta";
        deploy = {
          autoRollback = true;
          magicRollback = true;
        };
      };

      # The typical user in server environments.
      plover.systems = [ "x86_64-linux" ];
    };

    # Pretty much the baseline home-manager configuration for the whole
    # cluster.
    sharedModules = [
      # ...plus a bunch of third-party modules.
      inputs.sops-nix.homeManagerModules.sops
      inputs.nix-index-database.hmModules.nix-index

      # The rainbow road to ricing your raw materials.
      inputs.self.homeModules.bahaghari

      # The default shared config for our home-manager configurations. This
      # is also to be used for sharing modules among home-manager users from
      # NixOS configurations with `nixpkgs.useGlobalPkgs` set to `true` so
      # avoid setting nixpkgs-related options here.
      ({ pkgs, config, lib, ... }: {
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
      ../../modules/home-manager/profiles/nix-conf.nix

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
