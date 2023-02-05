{ stdenv
, lib
, fetchFromGitHub
, wrapQtAppsHook
, qtbase
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
  version = "unstable-2023-02-05";

  src = fetchFromGitHub {
    owner = "vgc";
    repo = "vgc";
    rev = "8e8d958ab9f7fa6f741346d60f17af44d7abb592";
    sha256 = "sha256-84dckIOrHmxVX7U7VM1Le6tEqG1cJYaAfBcbKqJ6Ros=";
    fetchSubmodules = true;
  };

  patches = [
    ./patches/set-reproducible-build.patch
  ];

  nativeBuildInputs = [ wrapQtAppsHook cmake ];

  buildInputs = [
    python3
    git
    freetype
    harfbuzz
    libGLU
    qtbase
  ];

  meta = with lib; {
    homepage = "https://www.vgc.io/";
    description =
      "Upcoming suite of vector-drawing applications that makes use of Vector Graphics Complex (VGC)";
    license = licenses.asl20;
  };
}
