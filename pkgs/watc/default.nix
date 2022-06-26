{ stdenv, lib, fetchhg, buildGoModule }:

buildGoModule rec {
  pname = "watc";
  version = "0.1.2";

  src = fetchhg {
    url = "https://humungus.tedunangst.com/r/watc";
    rev = "b0dc3d9fcecd";
    sha256 = "sha256-0JK9bu53xZvlDILpivY7PGWu/39OUj5mGE7oYbKx8uw=";
  };

  vendorSha256 = "sha256-O8RekYsjKF9OnBT3kXs0p5sJ67hc+VbT6qS3ra+AUkM=";

  meta = with lib; {
    homepage = "https://humungus.tedunangst.com/r/watc";
    description = "Prints a succinct status for a codebase";
    license = licenses.publicDomain;
  };
}
