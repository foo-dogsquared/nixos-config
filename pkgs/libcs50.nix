{ stdenv, lib, fetchFromGitHub, gnused }:

stdenv.mkDerivation rec {
  pname = "libcs50";
  version = "10.1.1";

  src = fetchFromGitHub {
    owner = "cs50";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256:0ckbhm3287yva94zqls8wi06bwk5f5386h5g1wz8jrlzwxw1s4ib";
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

