{ inputs

, defaultNixConf

, ...
}:

let
  domain = "foodogsquared.one";
  subdomain = name: "${name}.${domain}";
in
{
  setups.nixos = {
    configs = {
      # The main desktop.
      ni = {
        nixpkgs.branch = "nixos-unstable";

        # This is to make an exception for Archivebox.
        nixpkgs.config.permittedInsecurePackages = [
          "python3.12-django-3.1.14"
        ];

        systems = [ "x86_64-linux" ];
        formats = null;
        modules = [
          inputs.disko.nixosModules.disko
          inputs.sops-nix.nixosModules.sops

          inputs.wrapper-manager-fds.nixosModules.wrapper-manager
          {
            documentation.nixos.extraModules = [
              ../../modules/nixos
              ../../modules/nixos/_private
            ];
            wrapper-manager.documentation.manpage.enable = true;
            wrapper-manager.documentation.extraModules = [
              ../../modules/wrapper-manager
              ../../modules/wrapper-manager/_private
            ];
          }

          inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
          inputs.nixos-hardware.nixosModules.common-cpu-amd-raphael-igpu
        ];
        home-manager = {
          branch = "home-manager-unstable";
          nixpkgsInstance = "global";
          users.foo-dogsquared = {
            userConfig = {
              uid = 1000;
              extraGroups = [
                "adm"
                "adbusers"
                "wheel"
                "audio"
                "docker"
                "podman"
                "networkmanager"
                "systemd-journal"
                "wireshark"
              ];
              hashedPassword =
                "$6$.cMYto0K0CHbpIMT$dRqyKs4q1ppzmTpdzy5FWP/V832a6X..FwM8CJ30ivK0nfLjQ7DubctxOZbeOtygfjcUd1PZ0nQoQpOg/WMvg.";
              description = "Gabriel Arazas";
            };
          };
        };
        diskoConfigs = [ "laptop-ssd" ];
      };

      # A remote server.
      plover = {
        nixpkgs.branch = "nixos-unstable";
        home-manager.branch = "home-manager-unstable";
        systems = [ "x86_64-linux" ];
        inherit domain;

        formats = null;
        deploy = {
          hostname = subdomain "plover";
          autoRollback = true;
          magicRollback = true;
          activationTimeout = 1200;
        };

        modules = [
          inputs.disko.nixosModules.disko
          inputs.sops-nix.nixosModules.sops
        ];
      };

      # The barely customized non-graphical installer.
      bootstrap = {
        nixpkgs.branch = "nixos-unstable-small";
        systems = [ "aarch64-linux" "x86_64-linux" ];
        formats = [ "install-iso" ];
      };

      # The barely customized graphical installer.
      graphical-installer = {
        nixpkgs.branch = "nixos-unstable";
        home-manager.branch = "home-manager-unstable";
        systems = [ "aarch64-linux" "x86_64-linux" ];
        formats = [ "install-iso-graphical" ];
        diskoConfigs = [ "external-hdd" ];
        shouldBePartOfNixOSConfigurations = true;
      };

      # The WSL system (that is yet to be used).
      winnowing = {
        nixpkgs = {
          branch = "nixos-unstable";
          overlays = [
            inputs.neovim-nightly-overlay.overlays.default
          ];
        };
        home-manager.branch = "home-manager-unstable";
        systems = [ "x86_64-linux" ];
        formats = null;
        modules = [
          # Well, well, well...
          inputs.nixos-wsl.nixosModules.default
        ];
      };
    };

    # Basically the baseline NixOS configuration of the whole cluster.
    sharedModules = [
      # Only have third-party modules with optional NixOS modules.
      inputs.nix-index-database.nixosModules.nix-index

      # The rainbow road to ricing your raw materials.
      inputs.self.nixosModules.bahaghari

      # Bring our own teeny-tiny snippets of configurations.
      defaultNixConf
      ../../modules/nixos/profiles/generic.nix
      ../../modules/nixos/profiles/nix-conf.nix

      ({ lib, ... }: {
        home-manager.sharedModules = lib.singleton {
          xdg.userDirs.createDirectories = lib.mkDefault true;
          manual.html.enable = false;
        };
      })
    ];
  };

  flake = {
    # Listing my public NixOS modules if anyone cares.
    nixosModules.default = ../../modules/nixos;
  };
}
