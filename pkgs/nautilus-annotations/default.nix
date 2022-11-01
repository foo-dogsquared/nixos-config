{ stdenv
, lib
, fetchFromGitLab
, glib
, gnome
, gtksourceview5
, autoreconfHook
, wrapGAppsHook
, pkg-config
}:

stdenv.mkDerivation rec {
  pname = "nautilus-annotations";
  version = "0.10.0";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "madmurphy";
    repo = "nautilus-annotations";
    rev = version;
    sha256 = "sha256-obhy95HvlZuiqTf6IC+epqiWS8hcDHsOkYLSJ8LZ6z0=";
  };

  nativeBuildInputs =
    [ autoreconfHook glib gnome.nautilus pkg-config wrapGAppsHook ];

  buildInputs = [ gtksourceview5 ];

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
