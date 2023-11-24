{ stdenv, lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "awesome-cli";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "umutphp";
    repo = "awesome-cli";
    rev = "v${version}";
    sha256 = "sha256-gZNJVeFRGSDFHFjJ4KSSugsa6rR8YDMujg6PlRm2d7Q=";
  };

  vendorHash = "sha256-bqvcmIWy2fLpItE71LhGwuRK2+KPxNqMZalrFSCCSN0=";

  meta = with lib; {
    description = "Fancy terminal interface for navigating awesome lists";
    homepage = "https://github.com/umutphp/awesome-cli";
  };
}
