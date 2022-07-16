{ stdenv
, lib
, fetchFromGitHub
, meson
, ninja
, json-glib
, gtk4
, libxml2
, gobject-introspection
, pkg-config
, libadwaita
}:

stdenv.mkDerivation rec {
  pname = "text-engine";
  version = "0.1.0";
  src = fetchFromGitHub {
    owner = "mjakeman";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-TVQD5sAJJkcs/w4K5B3e+hvfTcoGXunsceada6k/Hjs=";
  };

  nativeBuildInputs = [ gobject-introspection gtk4 meson ninja pkg-config ];

  buildInputs = [ libadwaita json-glib libxml2 ];

  meta = with lib; {
    description = "Rich text framework for GTK";
    homepage = "https://github.com/mjakeman/text-engine";

    # TODO: Change this, plz.
    # Seems to be a modified version of MIT license.
    license = licenses.mit;
  };
}
