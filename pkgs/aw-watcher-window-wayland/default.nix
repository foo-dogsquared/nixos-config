{ stdenv
, lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, openssl
}:

rustPlatform.buildRustPackage rec {
  pname = "aw-watcher-window-wayland";
  version = "unstable-2023-08-03";

  src = fetchFromGitHub {
    owner = "ActivityWatch";
    repo = "aw-watcher-window-wayland";
    rev = "6108ad3df8e157965a43566fa35cdaf144b1c51b";
    hash = "sha256-xl9+k6xJp5/t1QPOYfnBLyYprhhrzjzByDKkT3dtVVQ=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "aw-client-rust-0.1.0" = "sha256-9tlVesnBeTlazKE2UAq6dzivjo42DT7p7XMuWXHHlnU=";
    };
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  env.OPENSSL_NO_VENDOR = "1";

  meta = with lib; {
    homepage = "https://github.com/ActivityWatch/aw-watcher-window-wayland";
    description = "ActivityWatch AFK and window watcher for Wayland";
    license = licenses.mpl20;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}
