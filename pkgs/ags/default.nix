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
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "Aylur";
    repo = "ags";
    rev = "v${version}";
    hash = "sha256-maDUYMdB0xyl9ju1pFfqaczlKyBizbG5UkE4DQ2D67w=";
    fetchSubmodules = true;
  };

  npmDepsHash = "sha256-e1YYtWiO/dN7w2s+En3+3gc98R/hM5pJnTK7kCCH8Mc=";

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
  };
}
