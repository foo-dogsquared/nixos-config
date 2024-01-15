{ inputs
, lib

, defaultSystem
, defaultExtraArgs
, defaultNixConf
, defaultHomeManagerConfig

, ...
}:

let
  inherit (import ../../lib/extras/flake-helpers.nix { inherit lib inputs; }) mkHost mkImage listImagesWithSystems;

  nixosConfigs = import ../../setups/nixos.nix { inherit lib inputs; };

  # A function that generates a NixOS module setting up the baseline
  # configuration for this project (or at least for this subset of NixOS
  # configurations).
  hostSpecificModule = host: metadata:
    let
      modules = metadata.modules or [ ];
      name = metadata._name or host;
    in
    { lib, ... }: {
      imports = modules ++ [
        inputs.${metadata.home-manager-channel or "home-manager"}.nixosModules.home-manager

        defaultNixOSConfig
        defaultNixConf
        ../nixos/${host}
      ];

      config = lib.mkMerge [
        {
          networking.hostName = lib.mkForce metadata.hostname or name;
          nixpkgs.hostPlatform = metadata._system or defaultSystem;

          # The global configuration for the home-manager module.
          home-manager.useUserPackages = lib.mkDefault true;
          home-manager.useGlobalPkgs = lib.mkDefault true;
          home-manager.sharedModules = [ defaultHomeManagerConfig ];
        }

        (lib.mkIf (metadata ? domain)
          { networking.domain = lib.mkForce metadata.domain; })
      ];
    };

  # The shared configuration for the entire list of hosts for this cluster.
  # Take note to only set as minimal configuration as possible since we're
  # also using this with the stable version of nixpkgs.
  defaultNixOSConfig = { options, config, lib, pkgs, ... }: {
    # Initialize some of the XDG base directories ourselves since it is
    # used by NIX_PROFILES to properly link some of them.
    environment.sessionVariables = {
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_STATE_HOME = "$HOME/.local/state";
    };

    # Only use imports as minimally as possible with the absolute
    # requirements of a host. On second thought, only on flakes with
    # optional NixOS modules.
    imports =
      # Append with our custom NixOS modules from the modules folder.
      import ../../modules/nixos { inherit lib; isInternal = true; }

      # Then, make the most with the modules from the flake inputs. Take
      # note importing some modules such as home-manager are as part of the
      # declarative host config so be sure to check out
      # `hostSpecificModule` function as well as the declarative host setup.
      ++ [
        inputs.nix-index-database.nixosModules.nix-index
        inputs.sops-nix.nixosModules.sops
        inputs.disko.nixosModules.disko
      ];

    _module.args = defaultExtraArgs;

    # Find Nix files with these! Even if nix-index is already enabled, it
    # is better to make it explicit.
    programs.command-not-found.enable = false;
    programs.nix-index.enable = true;

    # BOOOOOOOOOOOOO! Somebody give me a tomato!
    services.xserver.excludePackages = with pkgs; [ xterm ];

    # Append with the default time servers. It is becoming more unresponsive as
    # of 2023-10-28.
    networking.timeServers = [
      "europe.pool.ntp.org"
      "asia.pool.ntp.org"
      "time.cloudflare.com"
    ] ++ options.networking.timeServers.default;

    # Disable channel state files. This shouldn't break any existing
    # programs as long as we manage them NIX_PATH ourselves.
    nix.channel.enable = lib.mkDefault false;

    # Set several paths for the traditional channels.
    nix.nixPath = lib.mkIf config.nix.channel.enable
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

    # Please clean your temporary crap.
    boot.tmp.cleanOnBoot = lib.mkDefault true;

    # We live in a Unicode world and dominantly English in technical fields so we'll
    # have to go with it.
    i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

    # Enabling some things for sops.
    programs.gnupg.agent = lib.mkDefault {
      enable = true;
      enableSSHSupport = true;
    };
    services.openssh.enable = lib.mkDefault true;

    # It's following the 'nixpkgs' flake input which should be in unstable
    # branches. Not to mention, most of the system configurations should
    # have this attribute set explicitly by default.
    system.stateVersion = lib.mkDefault "23.11";
  };
in
{
  flake = {
    # Listing my public NixOS modules if anyone cares.
    nixosModules.default = import ../../modules/nixos { inherit lib; };

    # A list of NixOS configurations from the `./configs/nixos` folder starting
    # from project root. It also has some sensible default configurations.
    nixosConfigurations =
      lib.mapAttrs
        (user: metadata:
          mkHost {
            nixpkgs-channel = metadata.nixpkgs-channel or "nixpkgs";
            extraModules = [ (hostSpecificModule user metadata) ];
          })
        (listImagesWithSystems nixosConfigs);

    # Deploy them server configs like a lazy bum-bum.
    #
    # Anyways, don't forget to flush out your shell history regularly or make
    # it ignored which is a more ergonomic option.
    deploy.nodes =
      lib.mapAttrs'
        (name: value:
          let
            metadata = nixosConfigs.${name};
          in
          lib.nameValuePair "nixos-${name}" {
            hostname = metadata.deploy.hostname or name;
            autoRollback = metadata.deploy.auto-rollback or true;
            magicRollback = metadata.deploy.magic-rollback or true;
            fastConnection = metadata.deploy.fast-connection or true;
            remoteBuild = metadata.deploy.remote-build or false;
            profiles.system = {
              sshUser = metadata.deploy.ssh-user or "admin";
              user = "root";
              path = inputs.deploy.lib.${metadata.system or defaultSystem}.activate.nixos value;
            };
          })
        inputs.self.nixosConfigurations;
  };

  perSystem = { system, lib, ... }: {
    # This contains images that are meant to be built and distributed
    # somewhere else including those NixOS configurations that are built as
    # an ISO.
    images =
      let
        validImages = lib.filterAttrs
          (host: metadata:
             metadata.format != null && (lib.elem system metadata.systems))
          nixosConfigs;
      in
      lib.mapAttrs'
        (host: metadata:
          let
            name = metadata.hostname or host;
            nixpkgs-channel = metadata.nixpkgs-channel or "nixpkgs";
          in
          lib.nameValuePair name (mkImage {
            inherit (metadata) format;
            inherit nixpkgs-channel;
            extraModules = [
              (hostSpecificModule host metadata)

              # Forcing the host platform set by the host (if there's any).
              # Ideally, there shouldn't be.
              ({ lib, ... }: {
                nixpkgs.hostPlatform = lib.mkForce system;
              })
            ];
          }))
        validImages;
  };

  _module.args = {
    inherit defaultNixOSConfig nixosConfigs;
  };
}
