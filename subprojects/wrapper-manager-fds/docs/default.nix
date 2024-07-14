let
  sources = import ../npins;
in
{ pkgs ? import sources.nixos-unstable { } }:

let
  inherit (pkgs) nixosOptionDoc stdenv lib;
  wrapperManagerLib = import ../lib/env.nix;

  wrapperManagerEval = wrapperManagerLib.eval { inherit pkgs; };

  optionsDoc = nixosOptionDoc { inherit (wrapperManagerEval) options; };

  gems = pkgs.bundlerEnv {
    name = "wrapper-manager-fds-gem-env";
    ruby = pkgs.ruby_3_1;
    gemdir = ./.;
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "wrapper-manager-docs";
  version = "2024-07-13";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./assets
      ./config
      ./content
      ./layouts
    ];
  };

  buildInputs = with pkgs; [
    hugo
    go
    git
    gems
    gems.wrappedRuby
  ];

  patchPhase = ''
    runHook prePatch
    cp "${optionsDoc.optionsJSON}" > "${finalAttrs.src}/content/"
    runHook postPatch
  '';

  buildPhase = ''
    runHook preBuild
    hugo build
    runHook postBuild
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
})
