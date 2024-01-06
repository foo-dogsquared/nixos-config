# A very basic NixOS VM configuration intended for testing out the given
# workflow module. It's a good thing the baseline for the configuration is not
# tedious to set up for simpler configs like this.
{ workflow }:

let
  pkgs = import <nixpkgs> { };
  config' = import <config> { inherit pkgs; };
  lib = pkgs.lib.extend (import <config/lib/extras/extend-lib.nix>);

  modules = import <config/modules/nixos> { inherit lib; isInternal = true; };
  hmModules = import <config/modules/home-manager> { inherit lib; isInternal = true; };
  extraArgs = {
    nix-colors = import <nix-colors> { };
  };
in
import <nixpkgs/nixos/lib/eval-config.nix> {
  inherit lib;
  modules = modules ++ [
    <home-manager/nixos>
    <disko/module.nix>
    <sops-nix/modules/sops>
    <nixos-generators/formats/vm.nix>
    <nixos-generators/format-module.nix>
    ({ config, lib, pkgs, ... }: {
      imports = [
        (
          let
            password = "nixos";
          in
          lib.private.mapHomeManagerUser "alice" {
            inherit password;
            extraGroups = [
              "wheel"
            ];
            description = "The password is '${password}'";
            isNormalUser = true;
            createHome = true;
            home = "/home/alice";
          }
        )
      ];

      config = {
        home-manager.sharedModules = hmModules ++ [
          <sops-nix/modules/home-manager/sops.nix>
          ({ config, lib, ... }: {
            _module.args = extraArgs;

            nixpkgs.overlays = [
              config'.overlays.default
            ];
          })
        ];

        _module.args = extraArgs;

        virtualisation.qemu.options = [
          "-vga virtio"
          "-display gtk,gl=on"
        ];

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
