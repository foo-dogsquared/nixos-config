{ stdenv, lib, fetchFromGitLab, glib, nautilus, gtksourceview5, libadwaita
, autoreconfHook, wrapGAppsHook4, pkg-config }:

stdenv.mkDerivation rec {
  pname = "nautilus-annotations";
  version = "2.0.1";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "madmurphy";
    repo = "nautilus-annotations";
    rev = version;
    hash = "sha256-BivnmsACnpxdd6FV+ncdDd5ZwtJSSzNExoiCXeXIFkA=";
  };

  nativeBuildInputs =
    [ autoreconfHook glib nautilus pkg-config wrapGAppsHook4 ];

  buildInputs = [ libadwaita gtksourceview5 ];

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
