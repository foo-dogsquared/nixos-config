{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, openssl
}:

rustPlatform.buildRustPackage rec {
  pname = "fastn";
  version = "0.3.9";

  src = fetchFromGitHub {
    owner = "fastn-stack";
    repo = pname;
    rev = version;
    hash = "sha256-KhJc6cM1KnJSoaD3a0uRwlObGsu8p66gn4XAtFTHlVg=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "deadpool-0.9.5" = "sha256-4M2+nVVG/w0gnHkxTWVnfvy5HegW9A+nlWAkMltapeI=";
      "dioxus-core-0.3.2" = "sha256-jOVkqWPcGa/GGeZiQji7JbD2YF+qrXC9AZGozZg47+c=";
      "fbt-lib-0.1.18" = "sha256-xzhApWSVsVelii0R8vfB60kj0gA87MRTEplmX+UT96A=";
      "ftd-0.2.0" = "sha256-iHWR5KMgmo1QfLPc8ZKS4NvshXEg/OJw7c7fy3bs8v0=";
    };
  };

  OPENSSL_NO_VENDOR = "1";
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  checkFlags = [
    "--skip=tests::fbt"
  ];

  meta = with lib; {
    homepage = "https://fastn.com/";
    description = "An integrated development environment for FTD";
    license = licenses.bsd3;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}
