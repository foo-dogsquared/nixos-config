{ stdenv
, lib
, buildNpmPackage
, fetchFromGitHub
, meson
, ninja
, pkg-config
, gobject-introspection
, gjs
, gtk3
, libpulseaudio
}:

buildNpmPackage rec {
  pname = "ags";
  version = "unstable-2023-08-21";

  src = fetchFromGitHub {
    owner = "Aylur";
    repo = "ags";
    rev = "2a875d4813c52a1a97aab31fccaead74e4e46fea";
    hash = "sha256-zYvjFeKSDD6MM2j0UErsx6v43ikQHPFUklh9LnfGpUs=";
    fetchSubmodules = true;
  };

  npmDepsHash = "sha256-9EOpgm3Hg5MO9JIRNBgqmAA2Pf1QxgU1QGo+VVa1WjM=";

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    gjs
  ];

  buildInputs = [
    gjs
    gtk3
    libpulseaudio
  ];

  # TODO: I have no idea how to properly make use of the binaries from
  # node_modules folder, pls fix later (or is this the most Nix-idiomatic way of
  # doing this?). :(
  preConfigure = ''
    addToSearchPath PATH $PWD/node_modules/.bin
  '';

  meta = with lib; {
    homepage = "https://github.com/Aylur/ags";
    description = "A EWW-inspired widget system as a GJS library";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ foo-dogsquared ];
    platforms = platforms.linux;
  };
}
