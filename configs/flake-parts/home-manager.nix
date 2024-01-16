{ inputs
, lib

, defaultExtraArgs
, defaultNixConf

, ...
}:

let
  # The default config for our home-manager configurations. This is also to
  # be used for sharing modules among home-manager users from NixOS
  # configurations with `nixpkgs.useGlobalPkgs` set to `true` so avoid
  # setting nixpkgs-related options here.
  defaultHomeManagerConfig =
    { pkgs, config, lib, ... }: {
      # Set some extra, yeah?
      _module.args = defaultExtraArgs;

      # Hardcoding this is not really great especially if you consider using
      # other locales but its default values are already hardcoded so what
      # the hell. For other users, they would have to do set these manually.
      xdg.userDirs =
        let
          # The home directory-related options should be already taken care
          # of at this point. It is an ABSOLUTE MUST that it is set properly
          # since other parts of the home-manager config relies on it being
          # set properly.
          #
          # Here are some of the common cases for setting the home directory
          # options.
          #
          # * For exporting home-manager configurations, this is done in this
          #   flake definition.
          # * For NixOS configs, this is done automatically by the
          #   home-manager NixOS module.
          # * Otherwise, you'll have to manually set them.
          appendToHomeDir = path: "${config.home.homeDirectory}/${path}";
        in
        {
          desktop = appendToHomeDir "Desktop";
          documents = appendToHomeDir "Documents";
          download = appendToHomeDir "Downloads";
          music = appendToHomeDir "Music";
          pictures = appendToHomeDir "Pictures";
          publicShare = appendToHomeDir "Public";
          templates = appendToHomeDir "Templates";
          videos = appendToHomeDir "Videos";
        };

      programs.home-manager.enable = true;

      manual = lib.mkDefault {
        html.enable = true;
        json.enable = true;
        manpages.enable = true;
      };

      home.stateVersion = lib.mkDefault "23.11";
    };
in
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
      };

      plover.systems = [ "x86_64-linux" ];
    };

    # This is to be used by the NixOS `home-manager.sharedModules` anyways.
    sharedModules =
      # Import our own custom modules from here..
      import ../../modules/home-manager { inherit lib; isInternal = true; }

      # ...plus a bunch of third-party modules.
      ++ [
        inputs.sops-nix.homeManagerModules.sops
        inputs.nix-index-database.hmModules.nix-index

        defaultHomeManagerConfig
      ];

    standaloneConfigModules = [
      defaultNixConf

      ({ config, lib, ... }: {
        # Don't create the user directories since they are assumed to
        # be already created by a pre-installed system (which should
        # already handle them).
        xdg.userDirs.createDirectories = lib.mkForce false;

        programs.home-manager.enable = lib.mkForce true;
        targets.genericLinux.enable = true;
      })
    ];
  };

  flake = {
    # Extending home-manager with my custom modules, if anyone cares.
    homeModules.default = import ../../modules/home-manager { inherit lib; };
  };
}
