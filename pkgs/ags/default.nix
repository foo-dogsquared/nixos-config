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
  version = "unstable-2023-09-01";

  src = fetchFromGitHub {
    owner = "Aylur";
    repo = "ags";
    rev = "3d2171c850112ca37730fe6a8ed7c67192876dfc";
    hash = "sha256-WqCYukpjt0QNMDI9/K6PLw34R9OSBTMWIQD5LqeIsw8=";
    fetchSubmodules = true;
  };

  npmDepsHash = "sha256-uNdmlQIwXoO8Ls0qjJnwRGqpfiJK1PajAvoiHfJXcxg=";
  patches = [ ./lib-path.patch ];

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
