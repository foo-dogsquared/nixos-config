{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "GOL-C";
  version = "unstable-2022-03-25";

  src = fetchFromGitHub {
    owner = "FlynnOwen";
    repo = "GOL-C";
    rev = "02c76a178887c88aeff72e906c0dd5edba67aebe";
    sha256 = "sha256-tlNuAIQUIfvTjeWo7O6X0MLSGX1v7yFZTsatY8gWNxA=";
  };

  installPhase = ''
    install -Dm755 GOL -t $out/bin
  '';

  meta = with lib; {
    description = "Game of Life implementation in C";
    homepage = "https://github.com/FlynnOwen/GOL-C";
  };
}
