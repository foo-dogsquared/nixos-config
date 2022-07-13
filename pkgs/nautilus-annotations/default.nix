{ stdenv, lib, fetchgit, glib, gnome, gtksourceview4, autoreconfHook, wrapGAppsHook, pkg-config }:

stdenv.mkDerivation rec {
  pname = "nautilus-annotations";
  version = "0.8.4";

  src = fetchgit {
    url = "https://gitlab.gnome.org/madmurphy/nautilus-annotations.git";
    rev = version;
    sha256 = "sha256-wHM+ny4vhrV1Jyk9L6Qb8D556jntYAPG+ynGZLqpe6Q=";
  };

  nativeBuildInputs = [
    autoreconfHook
    glib
    gnome.nautilus
    pkg-config
    wrapGAppsHook
  ];

  buildInputs = [
    gtksourceview4
  ];

  preConfigure = ''
    ./bootstrap
  '';

  installFlags = [
    "NAUTILUS_EXTENSION_DIR=${placeholder "out"}/lib/nautilus/extensions-3.0"
  ];

  meta = with lib; {
    homepage = "https://gitlab.gnome.org/madmurphy/nautilus-annotations";
    description = "Nautilus extension that adds back file annotations";
    license = licenses.gpl3Only;
  };
}
