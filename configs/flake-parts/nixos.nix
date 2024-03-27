{ inputs

, defaultNixConf

, ...
}:

{
  setups.nixos = {
    configs = {
      # The main desktop.
      ni = {
        systems = [ "x86_64-linux" ];
        formats = null;
        modules = [
          inputs.disko.nixosModules.disko
          inputs.sops-nix.nixosModules.sops
        ];
        homeManagerUsers = {
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
      };

      # A remote server.
      plover = {
        systems = [ "x86_64-linux" ];
        formats = null;
        domain = "foodogsquared.one";
        modules = [
          inputs.disko.nixosModules.disko
          inputs.sops-nix.nixosModules.sops
        ];
        deploy = {
          hostname = "plover.foodogsquared.one";
          autoRollback = true;
          magicRollback = true;
        };
      };

      # TODO: Remove extra newlines that are here for whatever reason.
      #{{{
      void = {
        systems = [ "x86_64-linux" ];
        formats = [ "vm" ];
      };
      #}}}

      # The barely customized non-graphical installer.
      bootstrap = {
        systems = [ "aarch64-linux" "x86_64-linux" ];
        formats = [ "install-iso" ];
        nixpkgsBranch = "nixos-unstable-small";
      };

      # The barely customized graphical installer.
      graphical-installer = {
        systems = [ "aarch64-linux" "x86_64-linux" ];
        formats = [ "install-iso-graphical" ];
        diskoConfigs = [ "external-hdd" ];
        shouldBePartOfNixOSConfigurations = true;
      };

      # The WSL system (that is yet to be used).
      winnowing = {
        systems = [ "x86_64-linux" ];
        formats = null;
        overlays = [
          inputs.neovim-nightly-overlay.overlays.default
        ];
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
    ];
  };

  flake = {
    # Listing my public NixOS modules if anyone cares.
    nixosModules.default = ../../modules/nixos;
  };
}
