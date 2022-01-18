{ stdenv, lib, fetchFromGitHub, rustPlatform, meson, ninja, pkg-config
, wrapGAppsHook, gtk4, glib, gstreamer_1_18_5, gstreamer_plugins_base_1_18_5
, libadwaita, gobject-introspection, poppler_21_08, libxml2, appstream-glib
, desktop-file-utils, shared-mime-info }:

stdenv.mkDerivation rec {
  pname = "rnote";
  version = "0.2.5";

  src = fetchFromGitHub {
    owner = "flxzt";
    repo = "rnote";
    rev = "v${version}";
    sha256 = "sha256-4C0jsKmZeqzlEzJk9XLF41CZDFVsSklRmizY7N4zz+A=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    sha256 = "sha256-CvxUynDRnPGoqWxxzdZoQUys/kMwj3f9/IXVA4EqiNU=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    rustPlatform.rust.cargo
    rustPlatform.rust.rustc
    wrapGAppsHook
  ];

  buildInputs = [
    appstream-glib
    desktop-file-utils
    glib
    gobject-introspection
    gstreamer_1_18_5
    gstreamer_plugins_base_1_18_5
    gtk4
    libadwaita
    libxml2
    poppler_21_08
    shared-mime-info
  ];

  postPatch = ''
    patchShebangs build-aux/meson_post_install.py
  '';

  meta = with lib; {
    description = "Simple freehand drawing note-taking application";
    homepage = "https://github.com/flxzt/rnote";
    license = licenses.gpl3;
  };
}
