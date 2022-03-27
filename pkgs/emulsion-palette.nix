{ stdenv, lib, fetchFromGitHub, meson, ninja, vala, wrapGAppsHook4, libadwaita
, json-glib, libgee, pkg-config, gtk3, desktop-file-utils }:

stdenv.mkDerivation rec {
  pname = "emulsion-palette";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "lainsce";
    repo = "emulsion";
    rev = version;
    sha256 = "sha256-gwN+hpK/nZMyO2gqeoKxhsMM3k4sR0NuCkmnagMlpHA=";
  };

  nativeBuildInputs = [ meson ninja pkg-config vala wrapGAppsHook4 ];

  buildInputs = [
    desktop-file-utils
    gtk3 # We're only using it for the gtk-update-icon-cache utility.
    json-glib
    libadwaita
    libgee
  ];

  meta = with lib; {
    description = "Store your color palettes in an easy way";
    homepage = "https://github.com/lainsce/emulsion";
    license = licenses.gpl3Only;
  };
}
