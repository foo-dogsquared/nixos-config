# This shouldn't be a part of the foodogsquared's library set. These are simply
# environment builders used to build consistent environments throughout flake-
# and non-flake-based Nix environments. Much of the things here are unofficial
# and basically redoing what the upstream projects are doing so maintenance is
# pretty much higher here.
#
# Anyways, all we're doing here is to see how much of a pain to use those Nix
# projects especially those that are entirely relying on flakes.
#
# Despite named similarly to npins `sources` convention, it should also work
# for flake-based setups as long as the inputs attrset from the flake output
# function is the one that is passed.
{ lib, foodogsquaredLib, sources }:

let
  # A set of nixos-generators modules including our custom ones.
  nixosGeneratorModules =
    let
      officialFormats = builtins.readDir "${sources.nixos-generators}/formats";
      unofficialFormats = builtins.readDir ../modules/nixos-generators;
      formats = officialFormats // unofficialFormats;
    in
    lib.mapAttrs' (n: _: lib.nameValuePair (lib.removeSuffix ".nix" n) {
      imports = [
        "${sources.nixos-generators}/format-module.nix"
        (
          if (lib.hasAttr n officialFormats)
          then "${sources.nixos-generators}/formats/${n}"
          else "${../modules/nixos-generators}/${n}"
        )
      ];
    }) formats;
in
rec {
  mkNixosSystem = {
    pkgs,
    lib ? pkgs.lib,
    system,
    extraModules ? [ ],
    specialArgs ? { },
  }:
    let
      nixosModules = ../modules/nixos;

      # Evaluating the system ourselves (which is trivial) instead of relying
      # on nixpkgs.lib.nixosSystem flake output.
      nixosSystem = args: import "${pkgs.path}/nixos/lib/eval-config.nix" args;
    in
    (lib.makeOverridable nixosSystem) {
      inherit pkgs;
      specialArgs = specialArgs // {
        foodogsquaredUtils = import ./utils/nixos.nix { inherit lib; };
        foodogsquaredModulesPath = builtins.toString nixosModules;
      };
      modules = extraModules ++ lib.singleton {
        imports = [
          nixosModules
          ../modules/nixos/_private
        ];
        nixpkgs.hostPlatform = lib.mkForce system;
      };

      # Since we're setting it through nixpkgs.hostPlatform, we'll have to pass
      # this as null.
      system = null;
    };

  # A very very thin wrapper around `mkNixosSystem` to build with the given format.
  mkNixosImage = {
    pkgs,
    system,
    lib ? pkgs.lib,
    extraModules ? [ ],
    specialArgs ? { },
    format ? "iso",
  }:
    let
      extraModules' = extraModules ++ [ nixosGeneratorModules.${format} ];
      nixosSystem = mkNixosSystem {
        inherit pkgs lib system specialArgs;
        extraModules = extraModules';
      };
    in
    nixosSystem.config.system.build.${nixosSystem.config.formatAttr};

  mkHome = {
    pkgs,
    homeManagerSrc,
    lib ? pkgs.lib,
    modules ? [ ],
    specialArgs ? { },
  }:
    let
      homeModules = ../modules/home-manager;
    in
    import "${homeManagerSrc}/modules" {
      inherit pkgs lib;
      check = true;
      extraSpecialArgs = specialArgs // {
        foodogsquaredModulesPath = builtins.toString homeModules;
      };
      configuration = { lib, ... }: {
        imports = modules ++ lib.singleton {
          imports = [
            homeModules
            ../modules/home-manager/_private
          ];
        };
        config = {
          programs.home-manager.path = homeManagerSrc;
          inherit (pkgs) overlays;
          nixpkgs.config = lib.mkDefault pkgs.config;
        };
      };
    };

  mkWrapper = {
    pkgs,
    lib ? pkgs.lib,
    wrapperManagerSrc,
    modules ? [ ],
    specialArgs ? { },
  }:
    let
      wrapperManagerModules = ../modules/wrapper-manager;
      wrapperManager = import wrapperManagerSrc { };
    in
      wrapperManager.lib.build {
        inherit pkgs lib;
        specialArgs = specialArgs // {
          foodogsquaredModulesPath = builtins.toString wrapperManagerModules;
        };
        modules = modules ++ lib.singleton {
          imports = [
            wrapperManagerModules
            ../modules/wrapper-manager/_private
          ];
        };
      };
}
