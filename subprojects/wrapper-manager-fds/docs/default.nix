# I forgot about the fact Hugo also uses Go modules for its Hugo modules
# feature. For now, this is considered broken up until that is working. Also,
# Hugo has several features such as embedding metadata from VCS which doesn't
# play well with Nix that is requiring a clean source.
#
# For now, we're just relying on nix-shell to build it for us.
let
  sources = import ../npins;
in
{ pkgs ? import sources.nixos-unstable { } }:

let
  inherit (pkgs) nixosOptionsDoc stdenv lib;
  buildHugoSite = pkgs.callPackage ./hugo-build-module.nix { };
  wrapperManagerLib = import ../lib/env.nix;

  wrapperManagerEval = wrapperManagerLib.eval { inherit pkgs; };

  optionsDoc = nixosOptionsDoc { inherit (wrapperManagerEval) options; };

  gems = pkgs.bundlerEnv {
    name = "wrapper-manager-fds-gem-env";
    ruby = pkgs.ruby_3_1;
    gemdir = ./.;
  };

  # Now this is some dogfooding.
  asciidoctorWrapped =
    wrapperManagerLib.build {
      inherit pkgs;
      modules = [
        ({ config, lib, pkgs, ... }: {
          wrappers.asciidoctor = {
            arg0 = lib.getExe' gems "asciidoctor";
            appendArgs = [
              "-T" "${sources.website}/templates"
            ];
          };
        })
      ];
    };
in
buildHugoSite {
  pname = "wrapper-manager-docs";
  version = "2024-07-13";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./assets
      ./config
      ./content
      ./layouts
      ./go.mod
      ./go.sum
    ];
  };

  vendorHash = "sha256-vMLi8of2eF/s60B/lM3FDfSntEyieGkvJbTSMuI7Wws=";

  buildInputs = with pkgs; [
    asciidoctorWrapped
    hugo
    git
    gems
    gems.wrappedRuby
  ];

  installPhase = ''
    runHook preInstall
    cp --reflink=auto "$src/public" "$out"
    runHook postInstall
  '';

  meta = with lib; {
    description = "wrapper-manager-fds documentation";
    homepage = "https://github.com/foo-dogsquared/wrapper-manager-fds";
    license = with licenses; [
      mit
      fdl13Only
    ];
    platforms = platforms.all;
  };
}
