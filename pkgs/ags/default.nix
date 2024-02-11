{ lib
, buildNpmPackage
, fetchFromGitHub
, meson
, ninja
, pkg-config
, gobject-introspection
, gjs
, glib-networking
, gnome
, gtk-layer-shell
, libpulseaudio
, libsoup_3
, networkmanager
, upower
, wrapGAppsHook
, linux-pam
}:

buildNpmPackage rec {
  pname = "ags";
  version = "1.7.4";

  src = fetchFromGitHub {
    owner = "Aylur";
    repo = "ags";
    rev = "v${version}";
    hash = "sha256-n/NHEME+kCUIsvQhwEqqtIi14qd+/QsKFz+Bw7bEr8w=";
    fetchSubmodules = true;
  };

  npmDepsHash = "sha256-ucWdADdMqAdLXQYKGOXHNRNM9bhjKX4vkMcQ8q/GZ20=";

  mesonFlags = [
    (lib.mesonBool "build_types" true)
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gjs
    gobject-introspection
    wrapGAppsHook
  ];

  # Most of the build inputs here are basically needed for their typelibs.
  buildInputs = [
    gjs
    glib-networking
    gnome.gnome-bluetooth
    gtk-layer-shell
    libpulseaudio
    libsoup_3
    linux-pam
    networkmanager
    upower
  ];

  # TODO: I have no idea how to properly make use of the binaries from
  # node_modules folder, pls fix later (or is this the most Nix-idiomatic way of
  # doing this?). :(
  preConfigure = ''
    addToSearchPath PATH $PWD/node_modules/.bin
  '';

  postPatch = ''
    chmod u+x ./post_install.sh && patchShebangs ./post_install.sh
  '';

  meta = with lib; {
    homepage = "https://github.com/Aylur/ags";
    description = "A EWW-inspired widget system as a GJS library";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ foo-dogsquared ];
    mainProgram = "ags";
    platforms = platforms.linux;
  };
}
