{ stdenv, lib, fetchFromGitHub, libGLU, cmake, qtbase, wrapQtAppsHook }:

stdenv.mkDerivation rec {
  pname = "vpaint";
  version = "2022-01-11";

  src = fetchFromGitHub {
    owner = "dalboris";
    repo = pname;
    rev = "6b1bf57e3c239194443f7284adfd5c5326cd1bf2";
    sha256 = "sha256-0lI+BeynkZ2RfTJmJ9pOVNQ+UcrRSi4r+6hALJ1SMss=";
  };

  nativeBuildInputs = [ wrapQtAppsHook cmake ];
  buildInputs = [ qtbase libGLU ];

  installPhase = ''
    install -Dm644 src/VAC/libVAC.a -t $out/lib
    install -Dm755 src/Gui/VPaint -t $out/bin
    install -Dm644 ../examples/*.vec -t $out/share/${pname}/examples
  '';

  meta = with lib; {
    description = "Experimental vector graphics and 3D animation editor";
    homepage = "https://www.vpaint.org/";
    license = licenses.asl20;
  };
}
