# A very basic NixOS VM configuration intended for testing out the given
# workflow module. It's a good thing the baseline for the configuration is not
# tedious to set up for simpler configs like this. Just take note this is
# executed on a separate directory as its own so relative paths are moot.
{ workflow }:

let
  pkgs = import <nixpkgs> { };
  config' = import <config> { };
  lib = pkgs.lib;
in
import <nixpkgs/nixos/lib/eval-config.nix> {
  inherit lib;
  specialArgs = {
    foodogsquaredUtils = import <config/lib/utils/nixos.nix> { inherit lib; };
  };
  modules = [
    # You can include an extra set by setting `extra-config` as part of the
    # include path. It is expected that this will not be overridden by the
    # script or the build process.
    <extra-config/modules/nixos>

    <config/modules/nixos>
    <config/modules/nixos/_private>
    <config/modules/nixos/profiles/generic.nix>
    <config/modules/nixos/profiles/nix-conf.nix>
    <config/modules/nixos/profiles/desktop>
    <home-manager/nixos>
    <nixos-generators/formats/vm.nix>
    <nixos-generators/format-module.nix>
    ({ config, lib, pkgs, foodogsquaredUtils, ... }: {
      imports = [
        (foodogsquaredUtils.mapHomeManagerUser "alice" {
          password = "";
          extraGroups = [ "wheel" ];
          description = "There is no password";
          isNormalUser = true;
          createHome = true;
          home = "/home/alice";
        })
      ];

      config = {
        # Enable the display manager of choice.
        services.xserver.displayManager.gdm.enable = true;

        # Configure home-manager-related stuff.
        home-manager.useUserPackages = lib.mkDefault true;
        home-manager.useGlobalPkgs = lib.mkDefault true;
        home-manager.sharedModules = [
          # Same with home-manager modules.
          <extra-config/modules/nixos>

          <config/modules/home-manager>
          <config/modules/home-manager/_private>
          <sops-nix/modules/home-manager/sops.nix>
          ({ config, lib, ... }: {
            xdg.userDirs.createDirectories = lib.mkForce true;
          })
        ];

        # The main function of the configuration.
        workflows.workflows.${workflow}.enable = true;

        nixpkgs.overlays = [
          config'.overlays.default
        ];

        system.stateVersion = "23.11";
      };
    })
  ];
}
