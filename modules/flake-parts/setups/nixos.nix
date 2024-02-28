# This is the declarative host management converted into a flake-parts module.
# It also enforces a structure for declarative NixOS setups such as a mandatory
# inclusion of the home-manager NixOS module, a deploy-rs node, a hostname and
# an optional domain, and deploy-rs-related options so it isn't really made to
# be generic or anything like that.
{ config, lib, inputs, ... }:

let
  cfg = config.setups.nixos;
  nixosModules = ../../nixos;

  # This is used on a lot of the Nix modules below.
  partsConfig = config;

  # A thin wrapper around the NixOS configuration function.
  mkHost = { extraModules ? [ ], nixpkgsBranch ? "nixpkgs", system }:
    let
      nixpkgs = inputs.${nixpkgsBranch};

      # Just to be sure, we'll use everything with the given nixpkgs' stdlib.
      lib = nixpkgs.lib;

      # A modified version of `nixosSystem` from nixpkgs flake. There is a
      # recent change at nixpkgs (at 039f73f134546e59ec6f1b56b4aff5b81d889f64)
      # that prevents setting our own custom functions so we'll have to
      # evaluate the NixOS system ourselves.
      nixosSystem = args: import "${nixpkgs}/nixos/lib/eval-config.nix" args;
    in
    (lib.makeOverridable nixosSystem) {
      specialArgs = {
        foodogsquaredModulesPath = builtins.toString nixosModules;
      };
      modules = extraModules ++ [{
        nixpkgs.hostPlatform = lib.mkForce system;
      }];

      # Since we're setting it through nixpkgs.hostPlatform, we'll have to pass
      # this as null.
      system = null;
    };

  # The nixos-generators modules set as well as our custom-made ones.
  nixosGeneratorsModulesSet =
    let
      importNixosGeneratorModule = (_: modulePath: {
        imports = [
          modulePath
          "${inputs.nixos-generators}/format-module.nix"
        ];
      });

      customFormats = lib.mapAttrs importNixosGeneratorModule {
        install-iso-graphical = ../../nixos-generators/install-iso-graphical.nix;
      };
    in
    inputs.nixos-generators.nixosModules // customFormats;

  # A very very thin wrapper around `mkHost` to build with the given format.
  mkImage =
    { system
    , nixpkgsBranch ? "nixpkgs"
    , extraModules ? [ ]
    , format ? "iso"
    }:
    let
      extraModules' =
        extraModules ++ [ nixosGeneratorsModulesSet.${format} ];
      image = mkHost {
        inherit nixpkgsBranch system;
        extraModules = extraModules';
      };
    in
    image.config.system.build.${image.config.formatAttr};

  deployNodeType = { config, lib, ... }: {
    freeformType = with lib.types; attrsOf anything;
    imports = [ ./shared/deploy-node-type.nix ];

    options = {
      profiles = lib.mkOption {
        type = with lib.types; functionTo (attrsOf anything);
        default = os: {
          system = {
            sshUser = "root";
            user = "admin";
            path = inputs.deploy.lib.${os.system}.activate.nixos os.config;
          };
        };
        defaultText = lib.literalExpression ''
          os: {
            system = {
              sshUser = "root";
              user = "admin";
              path = <deploy-rs>.lib.''${os.system}.activate.nixos os.config;
            };
          }
        '';
        description = ''
          A set of profiles for the resulting deploy node.

          Since each config can result in more than one NixOS system, it has to
          be a function where the passed argument is an attribute set with the
          following values:

          * `name` is the attribute name from `configs`.
          * `config` is the NixOS configuration itself.
          * `system` is a string indicating the platform of the NixOS system.

          If unset, it will create a deploy-rs node profile called `system`
          similar to those from nixops.
        '';
      };
    };
  };

  homeManagerUserType = { name, config, lib, ... }: {
    options = {
      userConfig = lib.mkOption {
        type = with lib.types; attrsOf anything;
        description = ''
          The configuration applied for {option}`users.users.<name>` in the
          NixOS configuration.
        '';
      };

      additionalModules = lib.mkOption {
        type = with lib.types; listOf raw;
        description = ''
          A list of additional home-manager modules to be added with the
          user.
        '';
      };
    };

    config =
      let
        hmUserConfig = partsConfig.setups.home-manager.configs.${name};
      in
      {
        userConfig = {
          isNormalUser = lib.mkDefault true;
          createHome = lib.mkDefault true;
          home = lib.mkForce hmUserConfig.homeDirectory;
        };

        additionalModules = [
          ({ lib, ... }: {
            home.homeDirectory = lib.mkForce hmUserConfig.homeDirectory;
            home.username = lib.mkForce name;
          })
        ];
      };
  };

  configType = { config, name, lib, ... }: {
    options = {
      formats = lib.mkOption {
        type = with lib.types; nullOr (listOf str);
        default = [ "iso" ];
        description = ''
          The image formats to be generated from nixos-generators. When given
          as `null`, it is listed as part of `nixosConfigurations` and excluded
          from `images` flake output which is often the case for desktop NixOS
          systems.
        '';
      };

      overlays = lib.mkOption {
        type = with lib.types; listOf (functionTo raw);
        default = [ ];
        example = lib.literalExpression ''
          [
            inputs.neovim-nightly-overlay.overlays.default
            inputs.emacs-overlay.overlays.default
          ]
        '';
        description = ''
          A list of overlays to be applied for that host.
        '';
      };

      hostname = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = name;
        example = "MyWhatNow";
        description = "The hostname of the NixOS configuration.";
      };

      domain = lib.mkOption {
        type = with lib.types; nullOr nonEmptyStr;
        default = null;
        example = "work.example.com";
        description = "The domain of the NixOS system.";
      };

      nixpkgsBranch = lib.mkOption {
        type = lib.types.str;
        default = "nixpkgs";
        description = ''
          The nixpkgs branch to be used for evaluating the NixOS configuration.
          By default, it will use the `nixpkgs` flake input.

          ::: {.note}
          This is based from your flake inputs and not somewhere else. If you
          want to have support for multiple nixpkgs branch, simply add them as
          a flake input.
          :::
        '';
        example = "nixos-unstable-small";
      };

      homeManagerBranch = lib.mkOption {
        type = lib.types.str;
        default = "home-manager";
        example = "home-manager-stable";
        description = ''
          The home-manager branch to be used for the NixOS module. By default,
          it will use the `home-manager` flake input.
        '';
      };

      homeManagerUsers = lib.mkOption {
        type = lib.types.submodule {
          options = {
            users = lib.mkOption {
              type = with lib.types; attrsOf (submodule homeManagerUserType);
              default = { };
              description = ''
                A set of home-manager users from {option}`setups.home-manager` to be
                mapped within the NixOS system as a normal user with their
                home-manager configuration. This would be the preferred method of
                creating NixOS users if you have a more comprehensive home-manager
                user that needed more setup to begin with.
              '';
            };
            nixpkgsInstance = lib.mkOption {
              type = lib.types.enum [ "global" "separate" "none" ];
              default = "global";
              description = ''
                Indicates how to manage the nixpkgs instance (or instances)
                of the holistic system. This will also dictate how to import
                overlays from
                {option}`setups.home-manager.configs.<user>.overlays`.

                * `global` enforces to use one nixpkgs instance for all
                home-manager users and imports all of the overlays into the
                nixpkgs instance of the NixOS system.
                * `separate` enforces the NixOS system to use individual
                nixpkgs instance for all home-manager users and imports the
                overlays to the nixpkgs instance of the home-manager user.
                * `none` leave the configuration alone and do not import
                overlays at all where you have to set them yourself. This is
                the best option if you want more control over each individual
                NixOS and home-manager configuration.

                The default value is set to `global` which is the encouraged
                practice with this module.
              '';
            };
          };
        };
        default = { };
        example = lib.literalExpression ''
          {
            nixpkgsInstance = "global";
            users.foo-dogsquared = {
              userConfig = {
                extraGroups = [
                  "adbusers"
                  "wheel"
                  "audio"
                  "docker"
                  "podman"
                  "networkmanager"
                  "wireshark"
                ];
                hashedPassword =
                  "0000000000000000000000000000000000000000000000";
                isNormalUser = true;
                createHome = true;
                home = "/home/foo-dogsquared";
                description = "Gabriel Arazas";
              };
              additionalModules = [
                ({ config, lib, osConfig, ... }: {
                  programs.foo.enable = lib.mkIf osConfig.programs.bar.enable true;
                })
              ];
            };
          }
        '';
        description = ''
          Import home-manager users from
          {option}`setups.home-manager.configs` and map them as a normal
          NixOS user.
        '';
      };

      deploy = lib.mkOption {
        type = with lib.types; nullOr (submodule deployNodeType);
        default = null;
        description = ''
          deploy-rs node settings for the resulting NixOS configuration. When
          this attribute is given with a non-null value, it will be included in
          `nixosConfigurations` even if
          {option}`setups.nixos.configs.<config>.formats` is set.
        '';
        example = {
          hostname = "work1.example.com";
          fastConnection = true;
          autoRollback = true;
          magicRollback = true;
          remoteBuild = true;
        };
      };

      diskoConfigs = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
        example = [ "external-hdd" ];
        description = ''
          A list of declarative Disko configurations to be included alongside
          the NixOS configuration.
        '';
      };
    };

    config.modules = [
      # Bring in the required modules.
      inputs.${config.homeManagerBranch}.nixosModules.home-manager
      ../../../configs/nixos/${config.configName}

      # Mapping the declarative home-manager users (if it has one) into NixOS
      # users.
      (lib.mkIf (config.homeManagerUsers.users != { })
        (
          let
            setupConfig = config;
            hasHomeManagerUsers = config.homeManagerUsers.users != { };
            inherit (config.homeManagerUsers) nixpkgsInstance;
            isNixpkgs = state: hasHomeManagerUsers && nixpkgsInstance == state;
          in
          { config, lib, pkgs, ... }: {
            config = lib.mkMerge [
              (lib.mkIf hasHomeManagerUsers {
                users.users =
                  lib.mkMerge
                    (lib.mapAttrsToList
                      (name: hmUser: { ${name} = hmUser.userConfig; })
                      setupConfig.homeManagerUsers.users);

                home-manager.users = lib.mkMerge
                  (lib.mapAttrsToList
                    (name: hmUser: {
                      ${name} = { lib, ... }: {
                        imports =
                          partsConfig.setups.home-manager.configs.${name}.modules
                          ++ hmUser.additionalModules;
                      };
                    })
                    setupConfig.homeManagerUsers.users);
              })

              (lib.mkIf (isNixpkgs "global") {
                home-manager.useGlobalPkgs = lib.mkForce true;

                # Disable all options that are going to be blocked once
                # `home-manager.useGlobalPkgs` is used.
                home-manager.users =
                  lib.mkMerge
                    (lib.mapAttrsToList
                      (name: _: {
                        ${name} = {
                          nixpkgs.overlays = lib.mkForce null;
                          nixpkgs.config = lib.mkForce null;
                        };
                      })
                      setupConfig.homeManagerUsers.users);

                # Then apply all of the user overlays into the nixpkgs instance
                # of the NixOS system.
                nixpkgs.overlays =
                  let
                    hmUsersOverlays =
                      lib.mapAttrsToList
                        (name: _:
                          partsConfig.setups.home-manager.configs.${name}.overlays)
                        setupConfig.homeManagerUsers.users;

                    overlays = lib.lists.flatten hmUsersOverlays;
                  in
                  # Most of the overlays are going to be imported from a
                    # variable anyways. This should massively reduce the step
                    # needed for nixpkgs to do its thing.
                    #
                    # Though, it becomes unpredictable due to the way how the
                    # overlay list is constructed. However, this is much more
                    # preferable than letting a massive list with duplicated
                    # overlays from different home-manager users to be applied.
                  lib.lists.unique overlays;
              })

              (lib.mkIf (isNixpkgs "separate") {
                home-manager.useGlobalPkgs = lib.mkForce false;
                home-manager.users =
                  lib.mkMerge
                    (lib.mapAttrsToList
                      (name: _: {
                        ${name} = {
                          nixpkgs.overlays =
                            partsConfig.setups.home-manager.configs.${name}.overlays;
                        };
                      })
                      setupConfig.homeManagerUsers.users);
              })
            ];
          }
        ))

      # Next, we include the chosen NixVim configuration into NixOS.
      (lib.mkIf (config.nixvim.instance != null)
        (
          let
            setupConfig = config;
          in
          { lib, ... }: {
            imports = [ inputs.nixvim.nixosModules.nixvim ];

            programs.nixvim = { ... }: {
              enable = lib.mkDefault true;
              imports =
                partsConfig.setups.nixvim.configs.${config.nixvim.instance}.modules
                ++ partsConfig.setups.nixvim.sharedModules
                ++ setupConfig.nixvim.additionalModules;
            };
          }
        ))

      # Then we include the Disko configuration (if there's any).
      (lib.mkIf (config.diskoConfigs != [ ]) (
        let
          diskoConfigs =
            builtins.map (name: import ../../../configs/disko/${name}) config.diskoConfigs;
        in
        {
          imports =
            [ inputs.disko.nixosModules.disko ]
            ++ (lib.lists.flatten diskoConfigs);
        })
      )

      # Setting up the typical configuration.
      (
        let
          setupConfig = config;
        in
        { config, lib, ... }: {
          config = lib.mkMerge [
            {
              nixpkgs.overlays = setupConfig.overlays;
              networking.hostName = lib.mkDefault setupConfig.hostname;
            }

            (lib.mkIf (setupConfig.domain != null) {
              networking.domain = lib.mkDefault setupConfig.domain;
            })
          ];
        }
      )
    ];
  };
in
{
  options.setups.nixos = {
    sharedModules = lib.mkOption {
      type = with lib.types; listOf raw;
      default = [ ];
      description = ''
        A list of modules to be shared by all of the declarative NixOS setups.
      '';
    };

    configs = lib.mkOption {
      type = with lib.types; attrsOf (submoduleWith {
        specialArgs = { inherit (config) systems; };
        modules = [
          ./shared/config-options.nix
          ./shared/nixvim-instance-options.nix
          configType
        ];
      });
      default = { };
      description = ''
        An attribute set of metadata for the declarative NixOS setups. This
        will then be used for related flake outputs such as
        `nixosConfigurations` and `images`.

        ::: {.note}
        For `nixosConfigurations` output, each of them is a pure NixOS
        configuration where `nixpkgs.hostPlatform` is set and each of the
        config is renamed into `$CONFIGNAME-$SYSTEM` if the host is configured
        to have more than one system.
        :::
      '';
      example = lib.literalExpression ''
        {
          desktop = {
            systems = [ "x86_64-linux" "aarch64-linux" ];
            formats = null;
            modules = [
              inputs.nur.nixosModules.nur
            ];
            overlays = [
              # Neovim nightly!
              inputs.neovim-nightly-overlay.overlays.default

              # Emacs unstable version!
              inputs.emacs-overlay.overlays.default

              # Helix master!
              inputs.helix-editor.overlays.default

              # Access to NUR.
              inputs.nur.overlay
            ];
          };

          server = {
            systems = [ "x86_64-linux" "aarch64-linux" ];
            domain = "work.example.com";
            formats = [ "do" "linode" ];
            nixpkgsBranch = "nixos-unstable-small";
            deploy = {
              autoRollback = true;
              magicRollback = true;
            };
          };

          vm = {
            systems = [ "x86_64-linux" "aarch64-linux" ];
            formats = [ "vm" ];
          };
        }
      '';
    };
  };

  config = lib.mkIf (cfg.configs != { }) {
    setups.nixos.sharedModules = [
      # Import our own public NixOS modules.
      nixosModules

      # Import our private modules.
      ../../nixos/_private

      # Set the home-manager-related settings.
      ({ lib, ... }: {
        home-manager.sharedModules = partsConfig.setups.home-manager.sharedModules;

        # These are just the recommended options for home-manager that may be
        # the default value in the future but this is how most of the NixOS
        # setups are already done so...
        home-manager.useUserPackages = lib.mkDefault true;
        home-manager.useGlobalPkgs = lib.mkDefault true;
      })
    ];

    flake =
      let
        # A quick data structure we can pass through multiple build pipelines.
        pureNixosConfigs =
          let
            validConfigs =
              lib.filterAttrs (_: v: v.formats == null || v.deploy != null) cfg.configs;

            generatePureConfigs = hostname: metadata:
              lib.listToAttrs
                (builtins.map
                  (system:
                    lib.nameValuePair system (mkHost {
                      nixpkgsBranch = metadata.nixpkgsBranch;
                      extraModules = cfg.sharedModules ++ metadata.modules;
                      inherit system;
                    })
                  )
                  metadata.systems);
          in
          lib.mapAttrs generatePureConfigs validConfigs;
      in
      {
        nixosConfigurations =
          let
            renameSystem = name: system: config:
              lib.nameValuePair "${name}-${system}" config;
          in
          lib.concatMapAttrs
            (name: configs:
              lib.mapAttrs' (renameSystem name) configs)
            pureNixosConfigs;

        deploy.nodes =
          let
            validConfigs =
              lib.filterAttrs
                (name: _: cfg.configs.${name}.deploy != null)
                pureNixosConfigs;

            generateDeployNode = name: system: config:
              lib.nameValuePair "nixos-${name}-${system}"
                (
                  let
                    deployConfig = cfg.configs.${name}.deploy;
                    deployConfig' = lib.attrsets.removeAttrs deployConfig [ "profiles" ];
                  in
                  deployConfig'
                  // {
                    profiles =
                      cfg.configs.${name}.deploy.profiles {
                        inherit name config system;
                      };
                  }
                );
          in
          lib.concatMapAttrs
            (name: configs:
              lib.mapAttrs' (generateDeployNode name) configs)
            validConfigs;
      };

    perSystem = { system, lib, ... }: {
      images =
        let
          validImages = lib.filterAttrs
            (host: metadata:
              metadata.formats != null && (lib.elem system metadata.systems))
            cfg.configs;

          generateImages = name: metadata:
            let
              buildImage = format:
                lib.nameValuePair
                  "${name}-${format}"
                  (mkImage {
                    inherit (metadata) nixpkgsBranch;
                    inherit system format;
                    extraModules = cfg.sharedModules ++ metadata.modules;
                  });

              images =
                builtins.map buildImage metadata.formats;
            in
            lib.listToAttrs images;
        in
        lib.concatMapAttrs generateImages validImages;
    };
  };
}
