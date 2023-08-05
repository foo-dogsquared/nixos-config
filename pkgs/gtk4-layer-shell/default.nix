{ stdenv
, lib
, fetchFromGitHub
, meson
, ninja
, pkg-config
, wayland
, wayland-protocols
, gtk4

, gobject-introspection
, gtk-doc
, docbook-xsl-nons
, docbook_xml_dtd_43
, vala
, python3
, luajit
}:

stdenv.mkDerivation rec {
  pname = "gtk4-layer-shell";
  version = "1.0.1";
  outputs = [ "out" "dev" "devdoc" ];
  outputBin = "devdoc";

  src = fetchFromGitHub {
    owner = "wmww";
    repo = "gtk4-layer-shell";
    rev = "v${version}";
    hash = "sha256-MG/YW4AhC2joUX93Y/pzV4s8TrCo5Z/I3hAT70jW8dw=";
  };

  # It is encouraged to use these flags anyways.
  mesonFlags = [
    "-Dexamples=true"
    "-Ddocs=true"
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    gtk-doc
    docbook-xsl-nons
    docbook_xml_dtd_43
  ];

  buildInputs = [
    wayland
    wayland-protocols
    gtk4
    vala
  ];

  checkInputs = [
    python3
    (luajit.withPackages (ps: with ps; [ lgi ]))
  ];

  meta = with lib; {
    homepage = "https://github.com/wmww/gtk4-layer-shell";
    license = licenses.mit;
    description = "Library to create desktop components using Layer Shell protocol and GTK4";
    longDescription = ''
      gtk4-layer-shell is a library to create desktop components using Layer
      Shell protocol and GTK4. It can used to create components such as panels,
      wallpapers, and notifications. This library is written in C and
      compatible with C++ and with other languages through GObject
      introspection files.
    '';
    maintainers = with maintainers; [ foo-dogsquared ];
    platforms = platforms.linux;
  };
}
