{ stdenv, lib, fetchFromGitHub, wrapQtAppsHook, qtbase, cmake, python3, harfbuzz
, freetype, libGLU, git }:

stdenv.mkDerivation rec {
  pname = "vgc";
  version = "unstable-2024-08-16";

  src = fetchFromGitHub {
    owner = "vgc";
    repo = "vgc";
    rev = "f9814daf5b7d411feeca0a1d994b344243402989";
    sha256 = "sha256-86Ze8+aKMn0EU+RjcyUuDCCaEleh48gzyU9ZuYxpSdM=";
    fetchSubmodules = true;
  };

  patches = [ ./patches/set-reproducible-build.patch ];

  nativeBuildInputs = [ wrapQtAppsHook cmake ];

  buildInputs = [ python3 git freetype harfbuzz libGLU qtbase ];

  meta = with lib; {
    homepage = "https://www.vgc.io/";
    description =
      "Upcoming suite of vector-drawing applications that makes use of Vector Graphics Complex (VGC)";
    license = licenses.asl20;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}
