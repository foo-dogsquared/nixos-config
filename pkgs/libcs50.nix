{ stdenv, lib, fetchFromGitHub, gnused }:

stdenv.mkDerivation rec {
  pname = "libcs50";
  version = "11.0.1";

  src = fetchFromGitHub {
    owner = "cs50";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-/CLPhZecjbJMFcR5HM+Z7XSzpyEyjAN1zjgaXXmGKVc=";
  };

  makeFlags = [ "DESTDIR=$(out)" ];

  configurePhase = ''
    # Don't use ldconfig.
    ${gnused}/bin/sed -i -e '60,62d' Makefile
  '';

  meta = with lib; {
    homepage = "https://github.com/cs50/libcs50";
    description = "CS50 C library used for the problem sets";
    license = licenses.mit;
    platforms = platforms.all;
  };
}

