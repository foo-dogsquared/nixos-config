# The usual development shell of GNOME-related projects. It isn't really
# complete, it is more of a list of common applications for these types of
# projects.
#
# These include toolkits for C, Rust, and GNOME JavaScript.
{ mkShell
, cmake
, meson
, ninja
, gtk4
, libadwaita
, gjs
, pkg-config
, rustPlatform
, nodePackages
, blueprint-compiler
, desktop-file-utils
, librsvg
, gdk-pixbuf
, gst_all_1
, gettext
, glib
, appstream-glib
, json-glib
, gobject-introspection
, glib-networking
, glib-testing
, libsoup_3
}:

mkShell {
  packages = [
    meson # Their build system of choice.
    ninja # Their other build system of choice.
    cmake # Their other meta-build system of choice.
    pkg-config # That librarian in the background.
    gtk4 # The star of the show.
    libadwaita # The co-star of the show.

    # Common development inputs.
    desktop-file-utils
    librsvg
    gdk-pixbuf
    gst_all_1.gst-devtools
    gst_all_1.gst-libav
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-ugly
    gst_all_1.gstreamer
    gettext
    glib
    appstream-glib
    json-glib
    gobject-introspection
    glib-networking
    glib-testing
    libsoup_3

    # When Rust and GTK go together...
    rustPlatform.rust.cargo
    rustPlatform.rust.rustc

    # Creating desktop applications with JavaScript without Electron!
    nodePackages.typescript
    gjs

    # The new Blueprint language.
    blueprint-compiler
  ];
}
