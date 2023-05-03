{ stdenv, lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "wayback";
  version = "0.19.1";

  src = fetchFromGitHub {
    owner = "wabarc";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-LIWCT0/5T52VQQK4Dy6EFmFlJ02MkfvKddN/O/5zpZc=";
  };

  vendorSha256 = "sha256-TC4uwJswpD5oKqF/rpXqU/h+k0jErwhguT/LkdBA83Y=";
  doCheck = false;

  meta = with lib; {
    description =
      "Self-hosted toolkit for archiving webpages to the Internet Archive";
    homepage = "https://wabarc.eu.org/";
    license = licenses.gpl3Only;
  };
}
