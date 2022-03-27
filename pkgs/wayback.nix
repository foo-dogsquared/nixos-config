{ stdenv, lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "wayback";
  version = "0.17.0";

  src = fetchFromGitHub {
    owner = "wabarc";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-ookQz906ZY0I7aHyxOu+VpyoMxNrQLjuXTj78N9iS/A=";
  };

  vendorSha256 = "sha256-X73qMp+Xx/XxR6odxpZTywmjYPGcbLZBChC/SsqFNVs=";
  doCheck = false;

  meta = with lib; {
    description = "Self-hosted toolkit for archiving webpages to the Internet Archive";
    homepage = "https://wabarc.eu.org/";
    license = licenses.gpl3;
  };
}
