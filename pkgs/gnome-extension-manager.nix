{ stdenv, lib, fetchFromGitHub, wrapGAppsHook4, libadwaita, meson, ninja
, gettext, gtk4, appstream-glib, desktop-file-utils, gobject-introspection
, blueprint-compiler, pkg-config, json-glib, libsoup_3, glib, python3 }:

stdenv.mkDerivation rec {
  pname = "gnome-extension-manager";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "mjakeman";
    repo = "extension-manager";
    rev = "v${version}";
    sha256 = "sha256-4qfhRzPI9qPqTO5LTPP8PZLAiCmywC8j9L6Mi5sko6U=";
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
  ];

  # See https://github.com/NixOS/nixpkgs/issues/36468.
  mesonFlags = [ "-Dc_args=-I${glib.dev}/include/gio-unix-2.0" ];

  postPatch = ''
    chmod +x build-aux/meson/postinstall.py
    patchShebangs build-aux/meson/postinstall.py

    # Just to make sure.
    substituteInPlace build-aux/meson/postinstall.py \
      --replace "gtk-update-icon-cache" "gtk4-update-icon-cache"
  '';

  meta = with lib; {
    description = "Desktop app for managing GNOME shell extensions";
    homepage = "https://github.com/mjakeman/extension-manager";
  };
}
