{ stdenv, lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "clidle";
  version = "unstable-2022-03-02";

  src = fetchFromGitHub {
    owner = "ajeetdsouza";
    repo = "clidle";
    rev = "5e4a725489f9f39d107952cff8cd87d968a6b48b";
    sha256 = "sha256-6ZiBa7xNDys1zv/PdcG8XsJTqvMzaxdpYyB06pMYlI4=";
  };
  vendorSha256 = "sha256-YophzzTilKg+7QhthBr4G6vJBGt6l+9Y+I5E8Umuo8U=";

  meta = with lib; {
    description = "Play Wordle over SSH";
    homepage = "https://github.com/ajeetdsouza/clidle";
    license = licenses.mit;
  };
}
