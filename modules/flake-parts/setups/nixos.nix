# This is the declarative host management converted into a flake-parts module.
# It also enforces a structure for declarative NixOS setups such as a mandatory
# inclusion of the home-manager NixOS module, a deploy-rs node, a hostname and
# an optional domain, and deploy-rs-related options so it isn't really made to
# be generic or anything like that.
{ config, lib, inputs, ... }:

let
  cfg = config.setups.nixos;

  # A thin wrapper around the NixOS configuration function.
  mkHost = { extraModules ? [ ], nixpkgsBranch ? "nixpkgs", system }:
    let
      nixpkgs = inputs.${nixpkgsBranch};

      # Just to be sure, we'll use everything with the given nixpkgs' stdlib.
      lib' = nixpkgs.lib.extend (import ../../../lib/extras/extend-lib.nix);

      # A modified version of `nixosSystem` from nixpkgs flake. There is a
      # recent change at nixpkgs (at 039f73f134546e59ec6f1b56b4aff5b81d889f64)
      # that prevents setting our own custom functions so we'll have to
      # evaluate the NixOS system ourselves.
      nixosSystem = args: import "${nixpkgs}/nixos/lib/eval-config.nix" args;
    in
    (lib'.makeOverridable nixosSystem) {
      specialArgs = {
        foodogsquaredModulesPath = builtins.toString ../../nixos;
      };
      lib = lib';
      modules = extraModules ++ [{
        nixpkgs.hostPlatform = lib.mkForce system;
      }];

      # Since we're setting it through nixpkgs.hostPlatform, we'll have to pass
      # this as null.
      system = null;
    };

  # A very very thin wrapper around `mkHost` to build with the given format.
  mkImage = { system, nixpkgsBranch ? "nixpkgs", extraModules ? [ ], format ? "iso" }:
    let
      extraModules' =
        extraModules ++ [ inputs.nixos-generators.nixosModules.${format} ];
      image = mkHost {
        inherit nixpkgsBranch system;
        extraModules = extraModules';
      };
    in
    image.config.system.build.${image.config.formatAttr};

  deployNodeType = { config, lib, ... }: {
    freeformType = with lib.types; attrsOf anything;

    options = {
      fastConnection = lib.mkEnableOption "deploy-rs to assume the target machine is considered fast";
      autoRollback = lib.mkEnableOption "deploy-rs auto-rollback feature";
      magicRollback = lib.mkEnableOption "deploy-rs magic rollback feature";
      remoteBuild = lib.mkEnableOption "pass the build process to the remote machine";
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

  configType = { config, name, lib, ... }: {
    options = {
      systems = lib.mkOption {
        type = with lib.types; listOf str;
        default = lib.lists.take 1 config.systems;
        defaultText = "The first system listed from `config.systems`.";
        example = [ "x86_64-linux" "aarch64-linux" ];
        description = ''
          A list of platforms that the NixOS configuration is supposed to be
          deployed on.
        '';
      };

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

      modules = lib.mkOption {
        type = with lib.types; listOf raw;
        default = [ ];
        description = ''
          A list of NixOS modules specific for that host.
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
    };

    config = {
      modules = [
        inputs.${config.homeManagerBranch}.nixosModules.home-manager
        ../../../configs/nixos/${name}

        {
          nixpkgs.overlays = config.overlays;
          networking.hostName = lib.mkDefault config.hostname;
        }

        (lib.mkIf (config.domain != null) {
          networking.domain = lib.mkForce config.domain;
        })
      ];
    };
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
      type = with lib.types; attrsOf (submodule configType);
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
      {
        home-manager.useUserPackages = lib.mkDefault true;
        home-manager.useGlobalPkgs = lib.mkDefault true;
        home-manager.sharedModules = config.setups.home-manager.sharedModules;
      }
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
          lib.mapAttrs
            (hostname: metadata:
              generatePureConfigs hostname metadata)
            validConfigs;
      in
      {
        nixosConfigurations =
          lib.concatMapAttrs
            (name: configs:
              lib.mapAttrs'
                (system: config: lib.nameValuePair "${name}-${system}" config)
                configs)
            pureNixosConfigs;

        deploy.nodes =
          let
            validConfigs =
              lib.filterAttrs
                (name: _: cfg.configs.${name}.deploy != null)
                pureNixosConfigs;
          in
          lib.concatMapAttrs
            (name: configs:
              lib.mapAttrs'
                (system: config: lib.nameValuePair "nixos-${name}-${system}"
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
                  ))
                configs)
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
              images =
                builtins.map
                  (format:
                    lib.nameValuePair
                      "${name}-${format}"
                      (mkImage {
                        inherit (metadata) nixpkgsBranch;
                        inherit system format;
                        extraModules = cfg.sharedModules ++ metadata.modules;
                      }))
                  metadata.formats;
            in
              lib.listToAttrs images;
        in
        lib.concatMapAttrs
          (name: metadata: generateImages name metadata)
          validImages;
    };
  };
}
