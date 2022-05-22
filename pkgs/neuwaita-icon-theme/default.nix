{ stdenv, lib, fetchFromGitHub, gtk3, gnome-icon-theme, hicolor-icon-theme }:

stdenv.mkDerivation rec {
  pname = "neuwaita-icon-theme";
  version = "unstable-2022-05-22";

  src = fetchFromGitHub {
    owner = "Ashwatthaamaa";
    repo = "Neuwaita";
    rev = "319b751aaeb268e5c70f0000b25eea050ce3a2ff";
    sha256 = "sha256-eRpy1UaPtKOTzIUjWOn9z8TbtiNLv//c77rYrV4FHmI=";
  };

  nativeBuildInputs = [ gtk3 ];
  propagatedBuildInputs = [ gnome-icon-theme hicolor-icon-theme ];
  dontDropIconThemeCache = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 index.theme -t $out/share/icons/neuwaita
    cp -a scalable/ $out/share/icons/neuwaita
    gtk-update-icon-cache $out/share/icons/neuwaita

    runHook postInstall
  '';

  meta = with lib; {
    description = "A neumorphic take on Adwaita theme.";
    homepage = "https://github.com/Ashwatthaamaa/Neuwaita";
    #license = licenses.cc0;
    platforms = platforms.linux;
  };
}
