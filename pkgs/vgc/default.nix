{ stdenv
, lib
, fetchFromGitHub
, wrapQtAppsHook
, cmake
, python3
, harfbuzz
, freetype
, libGLU
, git
}:

# TODO: Get rid of the build date or at least set the build date to zero to be
# reproducible.
stdenv.mkDerivation rec {
  pname = "vgc";
  version = "2022-08-06";

  src = fetchFromGitHub {
    owner = "vgc";
    repo = "vgc";
    rev = "f0d99b02b6bb63cebee3de8f40dab72732da3271";
    sha256 = "sha256-LZG73LSM+q1TFFs+UkGB8S4eWPJu8VvRJsaGcqyTnu0=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ wrapQtAppsHook cmake harfbuzz ];

  buildInputs = [ python3 git freetype libGLU ];

  meta = with lib; {
    # Harfbuzz CMake path is not correct. See NixOS/nixpkgs#180054 for the
    # specific issue. Wait until this has been resolved.
    broken = true;
    homepage = "https://www.vgc.io/";
    description =
      "Upcoming suite of vector-drawing applications that makes use of Vector Graphics Complex (VGC)";
    license = licenses.asl20;
  };
}
