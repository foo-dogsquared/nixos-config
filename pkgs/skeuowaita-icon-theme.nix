{ stdenv, lib, fetchgit, gtk3, gnome-icon-theme, hicolor-icon-theme }:

stdenv.mkDerivation rec {
  pname = "skeuowaita-icon-theme";
  version = "unstable-2022-05-02";

  src = fetchgit {
    url = "https://gitlab.gnome.org/Conspiracy/skeuowaita.git";
    rev = "82e4b2e2bc5af4eb424061f4148f1dcac56a56d3";
    sha256 = "sha256-XnKnqE6qjKQQeIpZX5u298mbB7elsbkXmNYpgYefrNE=";
  };

  nativeBuildInputs = [ gtk3 ];
  propagatedBuildInputs = [ gnome-icon-theme hicolor-icon-theme ];
  dontDropIconThemeCache = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 index.theme -t $out/share/icons/skeuowaita
    cp -a scalable/ $out/share/icons/skeuowaita
    gtk-update-icon-cache $out/share/icons/skeuowaita

    runHook postInstall
  '';

  meta = with lib; {
    description = "A skeuomorphic take on Adwaita theme.";
    homepage = "https://gitlab.gnome.org/Conspiracy/skeuowaita";
    license = licenses.cc0;
    platforms = platforms.linux;
  };
}
