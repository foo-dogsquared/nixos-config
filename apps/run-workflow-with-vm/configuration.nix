{ workflow }:

let
  pkgs = import <nixpkgs> { };
  config' = import <config> { inherit pkgs; };
  lib = pkgs.lib.extend (self: super:
    let
      publicLib = import <config/lib> { lib = super; };
    in
    {
      inherit (publicLib) countAttrs getSecrets attachSopsPathPrefix;

      # Until I figure out how to properly add them only for their respective
      # environment, this is the working solution for now. Not really perfect
      # since we use one nixpkgs instance for each configuration (home-manager or
      # otherwise).
      private = publicLib
        // import <config/lib/private.nix> { lib = self; }
        // import <config/lib/home-manager.nix> { lib = self; };
    });

  modules = import <config/modules/nixos> { inherit lib; isInternal = true; };
  hmModules = import <config/modules/home-manager> { inherit lib; isInternal = true; };
in
import <nixpkgs/nixos/lib/eval-config.nix> {
  inherit lib;
  modules = modules ++ [
    <home-manager/nixos>
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
        home-manager.sharedModules = hmModules;

        _module.args = {
          nix-colors = import <nix-colors> { };
        };

        virtualisation.qemu.options = [
          "-vga virtio"
          "-display gtk,gl=on"
        ];

        workflows.workflows.${workflow}.enable = true;

        nixpkgs.overlays = [
          config'.overlays.default
        ];

        system.stateVersion = "23.11";
      };
    })
  ];
}
