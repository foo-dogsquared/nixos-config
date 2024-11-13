{ lib
, rustPlatform
, fetchFromGitHub
, cmake
, pkg-config
, openssl
}:

rustPlatform.buildRustPackage rec {
  pname = "fastn";
  version = "0.4.79";

  src = fetchFromGitHub {
    owner = "fastn-stack";
    repo = pname;
    rev = "f405500da3f3263f11b97ded059aeef9866a3454";
    hash = "sha256-nIq89Owf2znBYsdpq+2LpzplBdrnRldYa1at4VqiD3Q=";
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
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ foo-dogsquared ];
    mainProgram = "fastn";
  };
}
