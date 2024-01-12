# A very basic NixOS VM configuration intended for testing out the given
# workflow module. It's a good thing the baseline for the configuration is not
# tedious to set up for simpler configs like this.
{ workflow, extraModules ? [] }:

let
  pkgs = import <nixpkgs> { };
  config' = import <config>;
  lib = pkgs.lib.extend (import <config/lib/extras/extend-lib.nix>);

  modules = import <config/modules/nixos> { inherit lib; isInternal = true; };
  hmModules = import <config/modules/home-manager> { inherit lib; isInternal = true; };
  extraArgs = {
    nix-colors = import <nix-colors> { };
  };
in
import <nixpkgs/nixos/lib/eval-config.nix> {
  inherit lib;
  modules = modules ++ extraModules ++ [
    <home-manager/nixos>
    <disko/module.nix>
    <sops-nix/modules/sops>
    <nixos-generators/formats/vm.nix>
    <nixos-generators/format-module.nix>
    ({ config, lib, pkgs, ... }: {
      imports = [
        (lib.private.mapHomeManagerUser "alice" {
          password = "";
          extraGroups = [
            "wheel"
          ];
          description = "There is no password";
          isNormalUser = true;
          createHome = true;
          home = "/home/alice";
        })
      ];

      config = {
        home-manager.sharedModules = hmModules ++ [
          <sops-nix/modules/home-manager/sops.nix>
          ({ config, lib, ... }: {
            _module.args = extraArgs;
            xdg.userDirs.createDirectories = lib.mkForce true;

            nixpkgs.overlays = [
              config'.overlays.default
            ];
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
