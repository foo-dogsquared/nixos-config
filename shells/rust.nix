# This is just for a quick development setup. Otherwise, I recommend
# to use the `rust` template from `nixpkgs` or whatever you prefer.
{ mkShell
, openssl
, pkgconfig
, cargo
, rustc
, rustfmt
, rust-analyzer
, rustPackages
, rustPlatform
}:

mkShell {
  buildInputs = [
    openssl # In case some package needs it.
    pkgconfig # In case some other package needs it.

    # Rust platform.
    cargo
    rustc
    rustfmt
    rust-analyzer
  ];

  RUST_SRC_PATH = rustPlatform.rustLibSrc;
}
