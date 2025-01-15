{ stdenv, lib, fetchFromGitHub, autoreconfHook, bison, fftw, libtool, libjack2
, bluez, udev }:

stdenv.mkDerivation (finalAttrs: {
  pname = "pd-l2ork";
  version = "20241224";

  src = fetchFromGitHub {
    owner = "pd-l2ork";
    repo = "pd-l2ork";
    rev = finalAttrs.version;
    hash = "sha256-A+ETptD1R+Pb4r2qgD0YxV7KYeAb9iLBwENhYQyjBc4=";
  };

  nativeBuildInputs = [ libtool ];

  buildInputs = [ bison fftw libjack2 bluez udev ];

  meta = with lib; {
    homepage = "http://l2ork.music.vt.edu/";
    description = "Pure Data flavor based on Purr Data";
    license = licenses.bsd3;
    platforms = platforms.linux ++ platforms.darwin;
  };
})
