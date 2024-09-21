{ lib
, rustPlatform
, meson
, ninja
, pkg-config
}:

rustPlatform.buildRustPackage {
  pname = "app";
  version = "VERSION";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./Cargo.lock
      ./Cargo.toml
      ./LICENSE
      ./meson.build
      ./meson_options.txt
      ./src
    ];
  };

  cargoLock.lockFile = ./Cargo.lock;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  meta = with lib; {
    description = "Rust app";
    mainProgram = "app";
    platforms = platforms.unix;
  };
}
