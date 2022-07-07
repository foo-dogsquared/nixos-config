{ stdenv, lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "thokr";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "coloradocolby";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-OY7tSi9QoYXIQ+WvuuJ2akInEBsCNYHjwE1ailN3Pis=";
  };

  cargoSha256 = "sha256-gEpmXyLmw6bX3enA3gNVtXNMlkQl6J/8AwJQSY0RtFw=";

  meta = with lib; {
    homepage = "https://github.com/coloradocolby/thokr";
    description = "Sleek typing TUI written in Rust.";
    license = licenses.mit;
  };
}
