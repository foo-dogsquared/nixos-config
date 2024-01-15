{ inputs
, lib

, defaultSystem
, defaultExtraArgs
, defaultNixConf

, ...
}:

let
  homeManagerConfigs = import ../../setups/home-manager.nix { inherit lib inputs; };

  # The default config for our home-manager configurations. This is also to
  # be used for sharing modules among home-manager users from NixOS
  # configurations with `nixpkgs.useGlobalPkgs` set to `true` so avoid
  # setting nixpkgs-related options here.
  defaultHomeManagerConfig =
    { pkgs, config, lib, ... }: {
      imports =
        # Import our own custom modules from here..
        import ../../modules/home-manager { inherit lib; isInternal = true; }

        # ...plus a bunch of third-party modules.
        ++ [
          inputs.nur.hmModules.nur
          inputs.sops-nix.homeManagerModules.sops
          inputs.nix-index-database.hmModules.nix-index
          inputs.nix-colors.homeManagerModules.default
        ];

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

  # A function that generates a home-manager module from a given user
  # metadata.
  userSpecificModule = user: metadata:
    let
      name = metadata.username or metadata._name or user;
      modules = metadata.modules or [ ];
    in
    { lib, pkgs, config, ... }: {
      imports = modules ++ [
        defaultHomeManagerConfig
        defaultNixConf
        ../home-manager/${name}
      ];

      # Don't create the user directories since they are assumed to
      # be already created by a pre-installed system (which should
      # already handle them).
      xdg.userDirs.createDirectories = lib.mkForce false;

      # Setting the homely options.
      home.username = lib.mkForce name;
      home.homeDirectory = lib.mkForce (metadata.home-directory or "/home/${config.home.username}");

      programs.home-manager.enable = lib.mkForce true;
      targets.genericLinux.enable = true;
    };
in
{
  flake = {
    # Extending home-manager with my custom modules, if anyone cares.
    homeModules.default = import ../../modules/home-manager { inherit lib; };

    # Put them home-manager configurations.
    homeConfigurations =
      let
        inherit (import ../../lib/extras/flake-helpers.nix { inherit lib inputs; }) mkHome listImagesWithSystems;
      in
      lib.mapAttrs
        (user: metadata:
          mkHome {
            pkgs = import inputs.${metadata.nixpkgs-channel or "nixpkgs"} {
              system = metadata._system;
            };
            extraModules = [ (userSpecificModule user metadata) ];
            home-manager-channel = metadata.home-manager-channel or "home-manager";
          })
        (listImagesWithSystems homeManagerConfigs);

    # Include these as part of the deploy-rs nodes because why not.
    deploy.nodes =
      lib.mapAttrs'
        (name: value:
          let
            metadata = homeManagerConfigs.${name};
            username = metadata.deploy.username or name;
          in
          lib.nameValuePair "home-manager-${name}" {
            hostname = metadata.deploy.hostname or name;
            autoRollback = metadata.deploy.auto-rollback or true;
            magicRollback = metadata.deploy.magic-rollback or true;
            fastConnection = metadata.deploy.fast-connection or true;
            remoteBuild = metadata.deploy.remote-build or false;
            profiles.home = {
              sshUser = metadata.deploy.ssh-user or username;
              user = metadata.deploy.user or username;
              path = inputs.deploy.lib.${metadata.system or defaultSystem}.activate.home-manager value;
            };
          })
        inputs.self.homeConfigurations;
  };

  _module.args = {
    inherit homeManagerConfigs defaultHomeManagerConfig;
  };
}
