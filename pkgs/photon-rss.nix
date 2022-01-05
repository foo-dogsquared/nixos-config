{ stdenv, lib, fetchFromSourcehut, buildGoModule, xorg }:

buildGoModule rec {
  pname = "photon-rss";
  version = "2022-01-04-57687766";

  src = fetchFromSourcehut {
    owner = "~ghost08";
    repo = "photon";
    rev = "57687766a71add4751f68052666fed638fc45891";
    sha256 = "sha256-Q4WD1s9kvt5khvw9Zg7A688IECponIQ3HTAMoQpeQvY=";
  };

  buildInputs = [ xorg.libX11 ];
  vendorSha256 = "sha256-sASlZwJJzjMmzQRbCZfuuE7y9huO2dRYbYuzteIdLpI=";

  postInstall = ''
    # Move the plugins somewhere.
    install -Dm644 plugins/* -t $out/share/photon
  '';

  meta = with lib; {
    homepage = "https://git.sr.ht/~ghost08/photon";
    description = "RSS reader in the terminal with sixel support";
    license = licenses.gpl3;
  };
}
