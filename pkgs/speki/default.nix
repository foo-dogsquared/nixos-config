{ rustPlatform, lib, fetchFromGitHub, pkg-config, openssl, alsa-lib }:

rustPlatform.buildRustPackage rec {
  pname = "speki";
  version = "0.4.8";

  src = fetchFromGitHub {
    owner = "TBS1996";
    repo = "speki";
    rev = "v${version}";
    hash = "sha256-cvtMXtg2c9T4CaWAobagS9pW4pX4Q+nwdBvP+9A0er0=";
  };

  cargoLock = { lockFile = ./Cargo.lock; };

  env.OPENSSL_NO_VENDOR = "1";
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl alsa-lib ];

  # Most of the tests require filesystem access with the home directory so
  # we'll have to disable them for now.
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/TBS1996/speki/";
    description = "Flashcard app on the terminal";
    license = licenses.gpl2;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}
