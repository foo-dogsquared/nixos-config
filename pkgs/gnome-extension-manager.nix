{ stdenv
, lib
, fetchFromGitHub
, wrapGAppsHook4
, libadwaita
, meson
, ninja
, gettext
, gtk4
, appstream-glib
, desktop-file-utils
, gobject-introspection
, blueprint-compiler
, pkg-config
, json-glib
, libsoup_3
, glib
, python3
, text-engine
}:

stdenv.mkDerivation rec {
  pname = "gnome-extension-manager";
  version = "2022-07-20";

  src = fetchFromGitHub {
    owner = "mjakeman";
    repo = "extension-manager";
    rev = "71d7f47692dc981afbd1d4ca489d9406b1ba4efe";
    sha256 = "sha256-khw0drYn3AuAGeIN0dhU9bkgXoUb85rVxUrVCbTH9+g=";
  };

  nativeBuildInputs = [
    appstream-glib
    desktop-file-utils
    wrapGAppsHook4
    libadwaita
    meson
    pkg-config
    ninja
    gettext
    python3
  ];

  buildInputs = [
    blueprint-compiler
    gtk4
    gobject-introspection
    json-glib
    libsoup_3
    glib.dev
    glib
    text-engine
  ];

  # See https://github.com/NixOS/nixpkgs/issues/36468.
  mesonFlags = [ "-Dc_args=-I${glib.dev}/include/gio-unix-2.0" ];

  meta = with lib; {
    description = "Desktop app for managing GNOME shell extensions";
    homepage = "https://github.com/mjakeman/extension-manager";
    license = licenses.gpl3Only;
  };
}
