# This is the declarative user management converted into a flake-parts module.
{ config, lib, inputs, ... }:

let
  cfg = config.setups.home-manager;

  # A thin wrapper around the home-manager configuration function.
  mkHome = { system, nixpkgs-branch ? "nixpkgs", home-manager-branch ? "home-manager", extraModules ? [ ] }:
    let
      pkgs = inputs.${nixpkgs-branch}.legacyPackages.${system};
    in
    inputs.${home-manager-branch}.lib.homeManagerConfiguration {
      extraSpecialArgs = {
        foodogsquaredModulesPath = builtins.toString ../../home-manager;
      };

      inherit pkgs;
      lib = pkgs.lib.extend (import ../../../lib/extras/extend-lib.nix);
      modules = extraModules;
    };

  deploySettingsType = { config, lib, ... }: {
    freeformType = with lib.types; attrsOf anything;

    options = {
      fastConnection = lib.mkEnableOption "deploy-rs to assume the target machine is considered fast";
      autoRollback = lib.mkEnableOption "deploy-rs auto-rollback feature";
      magicRollback = lib.mkEnableOption "deploy-rs magic rollback feature";
      remoteBuild = lib.mkEnableOption "pass the build process to the remote machine";
      profiles = lib.mkOption {
        type = with lib.types; functionTo (attrsOf anything);
        default = os: {
          sshUser = "root";
          user = "admin";
          path = inputs.deploy-rs.lib.${os.system}.activate.nixos os.config;
        };
        defaultText = lib.literalExpression ''
          os: {
            sshUser = "root";
            user = "admin";
            path = inputs.deploy-rs.lib.''${os.system}.activate.nixos os.config;
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

          If unset, it will create a deploy-rs node profile called `home`
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
        example = [ "x86_64-linux" "aarch64-linux" ];
        description = ''
          A list of platforms that the NixOS configuration is supposed to be
          deployed on.
        '';
      };

      modules = lib.mkOption {
        type = with lib.types; listOf raw;
        default = [];
        description = ''
          A list of NixOS modules specific for that host.
        '';
      };

      overlays = lib.mkOption {
        type = with lib.types; listOf (functionTo raw);
        default = [];
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

      nixpkgs-branch = lib.mkOption {
        type = lib.types.str;
        default = "nixpkgs";
        example = "nixos-unstable-small";
        description = ''
          The nixpkgs branch to be used for evaluating the NixOS configuration.
          By default, it will use the `nixpkgs` flake input.

          ::: {.note}
          This is based from your flake inputs and not somewhere else. If you
          want to have support for multiple nixpkgs branch, simply add them as
          a flake input.
          :::
        '';
      };

      home-manager-branch = lib.mkOption {
        type = lib.types.str;
        default = "home-manager";
        example = "home-manager-stable";
        description = ''
          The home-manager branch to be used for the NixOS module. By default,
          it will use the `home-manager` flake input.
        '';
      };

      home-directory = lib.mkOption {
        type = lib.types.path;
        default = "/home/${name}";
        example = "/var/home/public-user";
        description = ''
          The home directory of the home-manager user.
        '';
      };

      deploy = lib.mkOption {
        type = with lib.types; nullOr (submodule deploySettingsType);
        default = null;
        description = ''
          deploy-rs settings to be passed onto the home-manager configuration node.
        '';
      };
    };

    config = {
      modules = [
        ../../../configs/home-manager/${name}

        {
          nixpkgs.overlays = config.overlays;
          home.username = lib.mkForce name;
          home.homeDirectory = lib.mkForce config.home-directory;
        }
      ];
    };
  };
in
{
  options.setups.home-manager = {
    sharedModules = lib.mkOption {
      type = with lib.types; listOf raw;
      default = [];
      description = ''
        A list of modules to be shared by all of the declarative home-manager
        setups.

        ::: {.note}
        Note this will be shared into NixOS as well through the home-manager
        NixOS module.
        :::
      '';
    };

    standaloneConfigModules = lib.mkOption {
      type = with lib.types; listOf raw;
      default = [];
      internal = true;
      description = ''
        A list of modules to be added alongside the shared home-manager modules
        in the standalone home-manager configurations.

        This is useful for modules that are only suitable for standalone
        home-manager configurations compared to home-manager configurations
        used as a NixOS module.
      '';
    };

    configs = lib.mkOption {
      type = with lib.types; attrsOf (submodule configType);
      default = {};
      description = ''
        An attribute set of metadata for the declarative home-manager setups.
      '';
      example = lib.literalExpression ''
        {
          foo-dogsquared = {
            systems = [ "aarch64-linux" "x86_64-linux" ];
            modules = [
              inputs.nur.hmModules.nur
              inputs.nixvim.homeManagerModules.nixvim
            ];
            overlays = [
              inputs.neovim-nightly-overlay.overlays.default
              inputs.emacs-overlay.overlays.default
              inputs.helix-editor.overlays.default
              inputs.nur.overlay
            ];
          };

          plover.systems = [ "x86_64-linux" ];
        }
      '';
    };
  };

  config = lib.mkIf (cfg.configs != {}) {
    flake =
      let
        # A quick data structure we can pass through multiple build pipelines.
        pureHomeManagerConfigs =
          let
            generatePureConfigs = username: metadata:
              lib.listToAttrs
                (builtins.map
                  (system:
                    let
                      name = "${username}-${system}";
                    in
                      lib.nameValuePair name (mkHome {
                        inherit (metadata) nixpkgs-branch home-manager-branch;
                        inherit system;
                        extraModules =
                          cfg.sharedModules
                          ++ cfg.standaloneConfigModules
                          ++ metadata.modules;
                      })
                  )
                  metadata.systems);
          in
          lib.mapAttrs
            (hostname: metadata:
              generatePureConfigs hostname metadata)
            cfg.configs;
      in
      {
      homeConfigurations =
        lib.concatMapAttrs
          (name: configs:
            lib.mapAttrs'
              (system: config: lib.nameValuePair "${name}-${system}" config)
              configs)
          pureHomeManagerConfigs;

      deploy.nodes =
        let
          validConfigs =
            lib.filterAttrs
              (name: _: cfg.configs.${name}.deploy != null)
              pureHomeManagerConfigs;
        in
        lib.concatMapAttrs
          (name: configs:
            lib.mapAttrs'
              (system: config: lib.nameValuePair "home-manager-${name}-${system}"
                (cfg.configs.${name}.deploy.profiles { inherit name config system; })))
          validConfigs;
    };
  };
}
