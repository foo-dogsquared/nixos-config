{ stdenv
, lib
, fetchFromGitHub
, rustPlatform
, pkg-config
, wrapGAppsHook4
, glib
, gobject-introspection
, libadwaita
, librsvg
, pango
, gtk4
, gdk-pixbuf
}:

rustPlatform.buildRustPackage rec {
  pname = "cosmic-launcher";
  version = "unstable-2022-09-25";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = pname;
    rev = "cf2df9ef966d14e979c653746b1502ae3a12ef5b";
    sha256 = "sha256-k0jDjezrzYrZr5moUCObQAJ4TDVJiwjG4waDR2gqKGA=";
  };

  cargoSha256 = "sha256-/tfJZCqlKQ2yo+4X6IdMwkUHGOq/lVR2BjvWAlGuJLc=";

  nativeBuildInputs = [
    wrapGAppsHook4
    pkg-config
    gobject-introspection
  ];

  buildInputs = [
    libadwaita
    glib
    gdk-pixbuf
    gtk4
    pango
    librsvg
  ];

  meta = with lib; {
    description = "GTK4 application runner frontend for Pop launcher";
    homepage = "https://github.com/pop-os/cosmic-launcher";
    license = licenses.mpl20;
  };
}
