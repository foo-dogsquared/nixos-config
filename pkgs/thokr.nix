{ stdenv, lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "thokr";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "coloradocolby";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-iIa8hALRTEHQe/OKTR1a6yvEw+2o8aQX95l43k2LbXo=";
  };

  cargoSha256 = "sha256-3oeQeJn7KHytDg1y2X6L5NCZdCLmgEjL3u2UC3Q4fZ8=";

  meta = with lib; {
    homepage = "https://github.com/coloradocolby/thokr";
    description = "Sleek typing TUI written in Rust.";
    license = licenses.mit;
  };
}
