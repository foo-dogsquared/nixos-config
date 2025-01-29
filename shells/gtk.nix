{ mkShell, lib, wrapGAppsHook, desktop-file-utils, glib, appstream-glib
, blueprint-compiler, libadwaita, libportal, libportal-gtk, gtk, meson, ninja
, pkg-config }:

mkShell {
  packages = [
    gtk
    glib
    meson
    ninja
    pkg-config

    appstream-glib
    desktop-file-utils

    blueprint-compiler
  ] ++ (lib.optionals (lib.versionAtLeast gtk.version "4.0") [
    libadwaita
    libportal
    libportal-gtk
  ]);

  inputsFrom = [ gtk ];
}
