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
    # Most of the build inputs are from `gtk` package. And since build
    # environment of the following packages is brought with `nix develop`, we
    # don't need to list much of the common build systems like Meson.
    wrapGAppsHook
    gtk

    glib
    appstream-glib
    desktop-file-utils

    blueprint-compiler
    libadwaita
    libportal
    libportal-gtk
  ];
}
