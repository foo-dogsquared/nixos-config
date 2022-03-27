{ stdenv, lib, fetchFromGitHub, wrapGAppsHook4, libadwaita, meson, ninja
, gettext, gtk4, appstream-glib, desktop-file-utils, gobject-introspection
, blueprint-compiler, pkg-config, json-glib, libsoup_3, glib, python3
, text-engine }:

stdenv.mkDerivation rec {
  pname = "gnome-extension-manager";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "mjakeman";
    repo = "extension-manager";
    rev = "v${version}";
    sha256 = "sha256-3mhz3MJC3/Gv841vaR7AMlh8WMxuVBQuHqwRMbbRGLo=";
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
  };
}
