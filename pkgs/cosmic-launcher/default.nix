{ stdenv
, lib
, fetchFromGitHub
, rustPlatform
, pkg-config
, wrapGAppsHook4
, glib
, gobject-introspection
, libadwaita
, pango
, gtk4
, gdk-pixbuf
}:

rustPlatform.buildRustPackage rec {
  pname = "cosmic-launcher";
  version = "2022-08-12";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = pname;
    rev = "e35ee8c05bfd3f2162baabe0ff5429a3ad27fead";
    sha256 = "sha256-czr9SD0awW/L1eitRgqd7gCk5RbC4eidT5x+u7i0PVY=";
  };

  cargoSha256 = "sha256-/nvJdkgOrw/dRqWErzQChHgaG+O++lVj7nqVoyFxkuo=";

  nativeBuildInputs = [ wrapGAppsHook4 pkg-config gobject-introspection ];

  buildInputs = [ libadwaita glib gdk-pixbuf gtk4 pango ];

  meta = with lib; {
    description = "GTK4 application runner frontend for Pop launcher";
    homepage = "https://github.com/pop-os/cosmic-launcher";
    license = licenses.mpl20;
  };
}
