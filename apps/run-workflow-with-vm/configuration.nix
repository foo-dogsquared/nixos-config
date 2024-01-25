# A very basic NixOS VM configuration intended for testing out the given
# workflow module. It's a good thing the baseline for the configuration is not
# tedious to set up for simpler configs like this.
{ workflow, extraModules ? [ ], extraHomeModules ? [ ] }:

let
  pkgs = import <nixpkgs> { };
  config' = import <config> { };
  lib = pkgs.lib.extend (import <config/lib/extras/extend-lib.nix>);

  extraArgs = {
    nix-colors = import <nix-colors> { };
  };
in
import <nixpkgs/nixos/lib/eval-config.nix> {
  inherit lib;
  modules = extraModules ++ [
    <config/modules/nixos>
    <config/modules/nixos/_private>
    <home-manager/nixos>
    <disko/module.nix>
    <sops-nix/modules/sops>
    <nixos-generators/formats/vm.nix>
    <nixos-generators/format-module.nix>
    ({ config, lib, pkgs, ... }: {
      imports = [
        (lib.private.mapHomeManagerUser "alice" {
          password = "";
          extraGroups = [ "wheel" ];
          description = "There is no password";
          isNormalUser = true;
          createHome = true;
          home = "/home/alice";
        })
      ];

      config = {
        home-manager.sharedModules = extraHomeModules ++ [
          <config/modules/home-manager>
          <config/modules/home-manager/_private>
          <sops-nix/modules/home-manager/sops.nix>
          ({ config, lib, ... }: {
            _module.args = extraArgs;
            xdg.userDirs.createDirectories = lib.mkForce true;
          })
        ];

        _module.args = extraArgs;

        workflows.workflows.${workflow}.enable = true;

        nixpkgs.overlays = [
          config'.overlays.default
        ];

        system.stateVersion = "23.11";

        home-manager.useUserPackages = lib.mkDefault true;
        home-manager.useGlobalPkgs = lib.mkDefault true;
      };
    })
  ];
}
