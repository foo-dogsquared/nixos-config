{ lib
, fetchFromGitHub
, rustPlatform
, pkg-config
, openssl
}:

rustPlatform.buildRustPackage rec {
  pname = "pigeon-mail";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "quambene";
    repo = "pigeon-rs";
    rev = "v${version}";
    hash = "sha256-qtyPSOG6QFbOM4i9XDXMz1Cmn9a5J8lLhnRkBIWz8Ic=";
  };

  cargoHash = "sha256-MRSO89qg08GyyIuzEpSO4qQTZS876U3SeGJ6eCO+3BA=";

  env = {
    OPENSSL_NO_VENDOR = "1";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  # It requires Postgres environment to test so that's a no-go for now.
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/quambene/pigeon-rs";
    description = "Email automation on the command line";
    license = licenses.asl20;
    maintainers = with maintainers; [ foo-dogsquared ];
    mainProgram = "pigeon";
    platform = platforms.unix;
  };
}
