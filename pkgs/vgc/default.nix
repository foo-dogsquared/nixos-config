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
  version = "unstable-2022-08-27";

  src = fetchFromGitHub {
    owner = "vgc";
    repo = "vgc";
    rev = "e7db360f27b059c3dfd0e002c6b29f6a558edd47";
    sha256 = "sha256-yHQKOMBfMVS9+mwulgTEFOl9bE5CA+psJUaE432YTmo=";
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
