# This is the declarative host management converted into a flake-parts module.
# It also enforces a structure for declarative NixOS setups such a deploy-rs
# node, a hostname and an optional domain, and deploy-rs-related options so it
# isn't really made to be generic or anything like that.
{ config, options, lib, inputs, ... }:

let
  cfg = config.setups.nixos;
  partsConfig = config;
  nixosModules = ../../nixos;

  # A thin wrapper around the NixOS configuration function.
  mkHost = {
    pkgs,
    lib ? pkgs.lib,
    system,
    extraModules ? [ ],
    specialArgs ? { },
  }:
    let
      # Evaluating the system ourselves (which is trivial) instead of relying
      # on nixpkgs.lib.nixosSystem flake output.
      nixosSystem = args: import "${pkgs.path}/nixos/lib/eval-config.nix" args;
    in
    (lib.makeOverridable nixosSystem) {
      inherit pkgs;
      specialArgs = specialArgs // {
        foodogsquaredUtils = import ../../../lib/utils/nixos.nix { inherit lib; };
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
  mkImage = {
    pkgs,
    system,
    extraModules ? [ ],
    format ? "iso",
  }:
    let
      extraModules' =
        extraModules ++ [ nixosGeneratorsModulesSet.${format} ];
      image = mkHost {
        inherit pkgs system;
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

  configType = { options, config, name, lib, ... }: let
    setupConfig = config;
  in {
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

      shouldBePartOfNixOSConfigurations = lib.mkOption {
        type = lib.types.bool;
        default = lib.isAttrs config.deploy || config.formats == null;
        example = true;
        description = ''
          Indicates whether the declarative NixOS setup should be included as
          part of the `nixosConfigurations` flake output.
        '';
      };
    };

    config.nixpkgs.config = cfg.sharedNixpkgsConfig;

    config.modules = [
      # Bring in the required modules.
      "${partsConfig.setups.configDir}/nixos/${config.configName}"

      # Setting up the typical configuration.
      (
        { config, lib, ... }: {
          config = lib.mkMerge [
            {
              nixpkgs.overlays = setupConfig.nixpkgs.overlays;
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
    sharedNixpkgsConfig = options.setups.sharedNixpkgsConfig // {
      description = ''
        Shared configuration between all of the nixpkgs instance of the
        declarative NixOS systems.

        ::: {.note}
        This is implemented since the way how NixOS systems built here are made
        with initializing a nixpkgs instance ourselves and NixOS doesn't allow
        configuring the nixpkgs instances that are already defined outside of
        its module environment.
        :::
      '';
    };

    sharedModules = lib.mkOption {
      type = with lib.types; listOf deferredModule;
      default = [ ];
      description = ''
        A list of modules to be shared by all of the declarative NixOS setups.
      '';
    };

    configs = lib.mkOption {
      type = with lib.types; attrsOf (submodule [
        (import ./shared/nix-conf.nix { inherit inputs; })
        (import ./shared/config-options.nix { inherit (config) systems; })
        ./shared/nixpkgs-options.nix
        configType
      ]);
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
            nixpkgs = {
              branch = "nixos-unstable";
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
          };

          server = {
            systems = [ "x86_64-linux" "aarch64-linux" ];
            domain = "work.example.com";
            formats = [ "do" "linode" ];
            nixpkgs.branch = "nixos-unstable-small";
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
    setups.nixos.sharedNixpkgsConfig = config.setups.sharedNixpkgsConfig;

    setups.nixos.sharedModules = [
      # Import our own public NixOS modules.
      nixosModules

      # Import our private modules.
      ../../nixos/_private
    ];

    flake =
      let
        # A quick data structure we can pass through multiple build pipelines.
        pureNixosConfigs =
          let
            validConfigs =
              lib.filterAttrs (_: v: v.shouldBePartOfNixOSConfigurations) cfg.configs;

            generatePureConfigs = hostname: metadata:
              lib.listToAttrs
                (builtins.map
                  (system:
                    let
                      nixpkgs = inputs.${metadata.nixpkgs.branch};

                      # We won't apply the overlays here since it is set
                      # modularly.
                      pkgs = import nixpkgs {
                        inherit system;
                        inherit (metadata.nixpkgs) config;
                      };
                    in
                    lib.nameValuePair system (mkHost {
                      inherit pkgs system;
                      extraModules = cfg.sharedModules ++ metadata.modules;
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
                  in
                  deployConfig
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
