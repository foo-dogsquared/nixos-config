{ stdenv, lib, fetchFromGitHub, qtbase, qt3d, qmake, wrapQtAppsHook, harfbuzz
, pkgconfig, mupdf, zlib, freetype, libGLU, gumbo, jbig2dec, openjpeg_2 }:

stdenv.mkDerivation rec {
  pname = "sioyek";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "ahrm";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-6eyUwrXeAkWpzwyIhWa/h6YZrSxztWwYBKCSnL2fsjE=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ qmake wrapQtAppsHook pkgconfig ];

  buildInputs = [
    qtbase
    qt3d
    harfbuzz

    # Replacing the application's vendored dependencies with the system
    # libraries.
    mupdf
    zlib

    # Since we're using libraries from the system, we'll also have to
    # link several libraries from the application manually.
    gumbo
    jbig2dec
    openjpeg_2
  ];

  postPatch = ''
    substituteInPlace pdf_viewer_build_config.pro \
      --replace "-Lmupdf/build/release -lmupdf -lmupdf-third -lmupdf-threads" "-L${mupdf.dev}/lib -lmupdf -lmupdf-third -lharfbuzz -lfreetype -lgumbo -ljbig2dec -lopenjp2 -ljpeg" \
      --replace 'INCLUDEPATH += ./pdf_viewer\' 'INCLUDEPATH += ./pdf_viewer ${mupdf.dev}/include ${zlib.dev}/include'

    # Remove and replace it with packages from nixpkgs
    sed -i -e '4,6d' pdf_viewer_build_config.pro
  '' + lib.optionalString stdenv.isLinux ''
    substituteInPlace pdf_viewer/main.cpp \
      --replace "/usr/share/sioyek" "$out/share/sioyek" \
      --replace "/etc/sioyek" "$out/etc/sioyek"
  '';

  qmakeFlags = lib.optional stdenv.isLinux "DEFINES+=LINUX_STANDARD_PATHS";

  preBuild = ''
    # Remove and replace it with packages from nixpkgs.
    rm -r mupdf zlib
  '';

  # Taken from `build_linux.sh` script.
  postInstall = ''
    install -Dm644 tutorial.pdf -t $out/share/sioyek
    install -Dm644 pdf_viewer/shaders/* -t $out/share/sioyek/shaders
    install -Dm644 pdf_viewer/keys.config -t $out/etc/sioyek
    install -Dm644 pdf_viewer/prefs.config -t $out/etc/sioyek
    install -Dm644 pdf_viewer/keys_user.config -t $out/share/sioyek
    install -Dm644 pdf_viewer/prefs_user.config -t $out/share/sioyek
  '';

  meta = with lib; {
    description =
      "PDF viewer designed for reading research papers and technical books";
    homepage = "https://sioyek.info";
    license = licenses.gpl3;
  };
}
