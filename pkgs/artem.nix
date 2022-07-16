{ stdenv, lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "artem";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "FineFindus";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-1unGpJA5SXVj+uZAXwiQyY9dYo3UkiX0MG+YYPbA8ac=";
  };

  cargoSha256 = "sha256-PBJU78j7YlNi0YQ9+LJafdHiCXXKsP43wHTIUZG3Zgs=";

  meta = with lib; {
    homepage = "https://github.com/FineFindus/artem";
    description =
      "Command-line application for converting images to ASCII art.";
    license = licenses.mpl20;
  };
}
