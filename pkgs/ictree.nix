{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "ictree";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "NikitaIvanovV";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-QDvAdNnc9+5GU6Rch/TDLs11O4dJrjDGskLzpTw7rbk=";
    fetchSubmodules = true;
  };

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "Like 'tree' but interactive";
    homepage = "https://github.com/NikitaIvanovV/ictree";
  };
}
