{ stdenv, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "moac";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "Seirdy";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-WpmO0VOSuwcoERLORool1IfeehqLdWN5ny/+TapkAm0=";
  };

  vendorHash = "sha256-5clp7s6xVUmniN5b9lFu/LW3CjDtgMMRzWIH+o7DnJQ=";

  doCheck = false;

  meta = with lib; {
    description = "Generic password generator and analyzer";
    homepage = "https://github.com/Seirdy/moac";
    license = licenses.mpl20;
  };
}
