{ lib
, rustPlatform
, fetchFromGitHub
, cmake
, pkg-config
, openssl
}:

rustPlatform.buildRustPackage rec {
  pname = "fastn";
  version = "0.4.75";

  src = fetchFromGitHub {
    owner = "fastn-stack";
    repo = pname;
    rev = version;
    hash = "sha256-8/0fOpZhboBJWN2sNrVD54uW3J3UPxGW9wil0UfdfuM=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "fastn-observer-0.1.0" = "sha256-D7ch6zB1xw54vGbpcQ3hf+zG11Le/Fy01W3kHhc8bOg=";
    };
  };

  OPENSSL_NO_VENDOR = "1";
  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ openssl ];

  checkFlags = [
    "--skip=tests::fbt"
  ];

  meta = with lib; {
    homepage = "https://fastn.com/";
    description = "An integrated development environment for FTD";
    license = licenses.bsd3;
    maintainers = with maintainers; [ foo-dogsquared ];
    mainProgram = "fastn";
  };
}
