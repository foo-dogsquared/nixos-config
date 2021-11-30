{ stdenv, lib, alsaLib, cmake, fetchFromGitHub, freeglut, gtk3, libGLU, libglvnd
, mesa, pkgconfig }:

stdenv.mkDerivation rec {
  pname = "tic-80";
  version = "ad6fac460480ca2eff25e6ef142460b9ff7bdcef";

  src = fetchFromGitHub {
    owner = "nesbox";
    repo = "TIC-80";
    rev = "8ba1ae484fed6904a76894804a99f4ea1e0af754";
    sha256 = "sha256-/BL7wbD/qeAWVJXAF4B6v5iD8SjjHKg48DBAjcXSa/I=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake pkgconfig ];

  buildInputs = [ alsaLib freeglut gtk3 libGLU libglvnd mesa ];

  cmakeFlags = [ "-DBUILD_PRO=ON" ];

  meta = with lib; {
    description = "A fantasy computer with built-in game dev tools.";
    homepage = "https://tic80.com/";
    license = licenses.mit;
  };
}

