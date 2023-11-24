{ stdenv, lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "clidle";
  version = "unstable-2022-07-07";

  src = fetchFromGitHub {
    owner = "ajeetdsouza";
    repo = "clidle";
    rev = "fe27556c1147333af2cfe81cbc40f4f60ea191ee";
    sha256 = "sha256-zSrCYNgN4wKFgRdog/7ANumy0GsqOMTHqLTT8p7LEgE=";
  };
  vendorHash = "sha256-YophzzTilKg+7QhthBr4G6vJBGt6l+9Y+I5E8Umuo8U=";

  meta = with lib; {
    description = "Play Wordle over SSH";
    homepage = "https://github.com/ajeetdsouza/clidle";
    license = licenses.mit;
  };
}
