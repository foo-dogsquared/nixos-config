{ lib, python3, fetchFromGitHub }:

with python3.pkgs;
buildPythonPackage rec {
  pname = "segno";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "heuer";
    repo = pname;
    rev = version;
    sha256 = "sha256-o83HmB4vGDP0P2Ep1eyO5QX8ihnW497ufRxiEEaG+hE=";
  };

  # TODO: Package the Python package for testing.
  doCheck = false;

  meta = with lib; {
    description = "Encode QR codes without dependencies (except Python).";
    homepage = "https://github.com/heuer/segno";
    license = licenses.bsd3;
  };
}
