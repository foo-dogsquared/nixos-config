{ stdenv, lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "hoppscotch-cli";
  version = "0.0.8";

  src = fetchFromGitHub {
    owner = "hoppscotch";
    repo = "hopp-cli";
    rev = "v${version}";
    sha256 = "sha256-9Xktvmh1DsywIkoy2AV24WBL93/4bVcv8t8tFC89gBo=";
  };

  vendorSha256 = "sha256-0G4GWbcrsvgJrkjv0IZPXxXheUQg8m/S+ClJUCtztLo=";

  meta = with lib; {
    description = "HTTP client for Hoppscotch";
    homepage = "https://hoppscotch.io/";
    license = licenses.mit;
  };
}
