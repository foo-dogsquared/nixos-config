{ stdenv, lib, fetchFromGitHub, python3Packages, wrapGAppsHook4, gtk4, gettext, libadwaita, gst_all_1, meson, pkg-config, ninja, gobject-introspection, glib, libsoup_3, blueprint-compiler, desktop-file-utils }:

python3Packages.buildPythonApplication rec {
  pname = "gnome-dialect";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "dialect-app";
    repo = "dialect";
    rev = version;
    fetchSubmodules = true;
    sha256 = "sha256-Ke23QnvKpmyuaqkiBQL1cUa0T7lSfYPLFi6wa9G8LYk=";
  };

  nativeBuildInputs = [
    blueprint-compiler
    desktop-file-utils
    gettext
    glib
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gobject-introspection
    gst_all_1.gstreamer
    gtk4
    libadwaita
    libsoup_3
  ];

  propagatedBuildInputs = with python3Packages; [
    pygobject3
    gtts
    dbus-python
  ];

  postPatch = ''
    rm -rf subprojects
  '';

  format = "other";
  meta = with lib; {
    homepage = "https://github.com/dialect-app/dialect";
    description = "Translation app for GNOME";
    license = licenses.gpl3Only;
  };
}
