{ stdenv, lib, fetchhg, buildGoModule }:

buildGoModule rec {
  pname = "watc";
  version = "0.1.2";

  src = fetchhg {
    url = "https://humungus.tedunangst.com/r/watc";
    rev = "b0dc3d9fcecd";
    sha256 = "";
  };

  vendorSha256 = "";

  meta = with lib; {
    homepage = "https://humungus.tedunangst.com/r/watc";
    description = "Prints a succinct status for a codebase";
    license = licenses.publicDomain;
  };
}
