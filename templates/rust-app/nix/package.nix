{ lib, stdenv, rustPlatform, cargo, rustc, meson, ninja, pkg-config }:

let metadata = lib.importTOML ../Cargo.toml;
in stdenv.mkDerivation (finalAttrs: {
  pname = metadata.package.name;
  version = metadata.package.version;

  src = lib.fileset.toSource {
    root = ../.;
    fileset =
      lib.fileset.unions [ ../Cargo.lock ../Cargo.toml ../src ../meson.build ];
  };

  nativeBuildInputs =
    [ meson ninja pkg-config rustPlatform.cargoSetupHook cargo rustc ];

  meta = with lib; {
    description = metadata.package.description;
    mainProgram = metadata.package.name;
    platforms = platforms.unix;
    license = with licenses; [ ];
  };
})
