{ lib
, config
, pkgs
, foodogsquaredLib
, foodogsquaredUtils
, foodogsquaredModulesPath

, ... }:

# Since this will be exported as an installer ISO, you'll have to keep in mind
# about the added imports from nixos-generators. In this case, it simply adds
# the NixOS installation CD profile.
{
  imports = [
    "${foodogsquaredModulesPath}/profiles/installer.nix"

    (foodogsquaredUtils.mapHomeManagerUser "nixos" { })
  ];

  config = lib.mkMerge [
    {
      # Use the systemd-boot EFI boot loader.
      boot.loader.systemd-boot = {
        enable = true;
        netbootxyz.enable = true;
      };
      boot.loader.efi.canTouchEfiVariables = true;
      boot.kernelPackages = pkgs.linuxPackages_6_6;

      # We'll make NetworkManager manage all of them networks.
      networking.wireless.enable = false;

      # Use my desktop environment configuration without the apps just to make the
      # closure size smaller.
      workflows.workflows.a-happy-gnome = {
        enable = true;
        extraApps = [ ];
      };

      # Install the web browser of course. What would be a graphical installer
      # without one, yes?
      programs.firefox = {
        enable = true;
        package = pkgs.firefox-foodogsquared-guest;
      };

      # Some niceties.
      suites.desktop.enable = true;

      services.xserver.displayManager = {
        gdm = {
          enable = true;
          autoSuspend = false;
        };
        autoLogin = {
          enable = true;
          user = "nixos";
        };
      };

      system.stateVersion = "23.11";
    }

    (lib.mkIf
      (foodogsquaredLib.isFormat "graphicalIsoImage") {
      isoImage = {
        isoBaseName = config.networking.hostName;
        edition = "A Happy GNOME";

        squashfsCompression = "zstd -Xcompression-level 12";
      };
    })
  ];
}
