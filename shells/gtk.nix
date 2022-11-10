{ mkShell
, wrapGAppsHook
, desktop-file-utils
, glib
, appstream-glib
, blueprint-compiler
, libadwaita
, libportal
, libportal-gtk
, gtk
}:

mkShell {
  packages = [
    gtk
    glib
    appstream-glib
    desktop-file-utils

    blueprint-compiler
    libadwaita
    libportal
    libportal-gtk
  ];

  inputsFrom = [ gtk ];
}
