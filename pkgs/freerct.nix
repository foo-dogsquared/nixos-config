{ lib, stdenv, fetchFromGitHub, cmake, libpng, SDL2, SDL2_ttf, flex, bison }:

stdenv.mkDerivation rec {
  pname = "freerct";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "FreeRCT";
    repo = "FreeRCT";
    rev = version;
    sha256 = "sha256-kftKFB/78LR6aO1ey8G3JQIVfdvp3lS7J9c5gpnw/Os=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    libpng
    SDL2
    SDL2_ttf
    flex
    bison
  ];

  meta = with lib; {
    homepage = "https://freerct.net/";
    description = "Free and open source game aiming to capture the look and feel of RollerCoaster Tycoon.";
    license = licenses.gpl2Only;
  };
}
