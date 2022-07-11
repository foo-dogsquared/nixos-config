{ stdenv, lib, fetchFromGitHub, python3Packages, wrapGAppsHook4, gtk4, gettext, libadwaita, gst_all_1, meson, pkg-config, ninja, gobject-introspection, glib, libsoup_3, blueprint-compiler, desktop-file-utils }:

python3Packages.buildPythonApplication rec {
  pname = "gnome-dialect";
  version = "unstable-2022-07-11";

  src = fetchFromGitHub {
    owner = "dialect-app";
    repo = "dialect";
    rev = "9dc46a6a52a2b10ce2956e6b48987ca55fa77033";
    fetchSubmodules = true;
    sha256 = "sha256-z/KVGdICwR/kuKjy2eEPS5XEwFsUc7jSHS7RLn87EhQ=";
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
