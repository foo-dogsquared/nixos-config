{ stdenv, lib, fetchFromGitHub, cmake, notcurses, ncurses }:

stdenv.mkDerivation rec {
  pname = "cursedgl";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "saccharineboi";
    repo = "CursedGL";
    rev = "v${version}";
    sha256 = "sha256-h4gDF0yVbCEj4uE/QVg0WLmQuiRkFX1dHo0ULcYSVYg=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ ncurses notcurses ];

  patches = [
    ./patches/update-cmakelist.patch
  ];

  meta = with lib; {
    description = "Notcurses-based software rasterizer";
    homepage = "https://github.com/saccharineboi/CursedGL";
    license = licenses.gpl3;
  };
}
