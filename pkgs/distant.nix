{ stdenv
, lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, openssl
}:

rustPlatform.buildRustPackage rec {
  version = "0.20.0";
  pname = "distant";

  src = fetchFromGitHub {
    owner = "chipsenkbeil";
    repo = "distant";
    rev = "v${version}";
    hash = "sha256-DcnleJUAeYg3GSLZljC3gO9ihiFz04dzT/ddMnypr48=";
  };
  cargoHash = "sha256-7MNNdm4b9u5YNX04nBtKcrw+phUlpzIXo0tJVfcgb40=";

  # Too many tests failing for now so we'll have to disable them. Much of the
  # failed tests require a home directory and network access.
  doCheck = false;

  # We'll just tell to use the system's openssl to build openssl-sys.
  env.OPENSSL_NO_VENDOR = 1;
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  meta = with lib; {
    description = "Remotely edit files and run programs";
    homepage = "https://github.com/chipsenkbeil/distant";
    license = lib.licenses.mit;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}
