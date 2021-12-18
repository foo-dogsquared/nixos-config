{ stdenv, lib, fetchFromGitHub, ncurses, autoreconfHook, libtool
, autoconf-archive }:

stdenv.mkDerivation rec {
  pname = "neo";
  version = "0.6";

  src = fetchFromGitHub {
    owner = "st3w";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-0ELYLV7sB/HhmTf9cN+6ejyhZq/pjdHgwi9V53eT61M=";
  };

  buildInputs = [ autoreconfHook autoconf-archive ncurses ];

  meta = with lib; {
    description = "Simulates the digital rain from 'The Matrix'";
    homepage = "https://github.com/st3w/neo";
    license = licenses.gpl3;
  };
}
