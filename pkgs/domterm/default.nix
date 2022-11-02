{ lib
, stdenv
, fetchFromGitHub
, autoreconfHook
, desktop-file-utils
, pkg-config
, libwebsockets
, json_c
, openssl
, asciidoctor
, unixtools
, zlib
, rustPlatform
, qt5
}:

stdenv.mkDerivation rec {
  pname = "domterm";
  version = "unstable-2022-11-02";

  src = fetchFromGitHub {
    owner = "PerBothner";
    repo = "DomTerm";
    rev = "71f726c387c708fd4c3a4363771afdcd1993b9eb";
    sha256 = "sha256-De3AnruWFK73TgGFWzOC0GaHjIW52pEqPwhRj9/RQx4=";
  };

  nativeBuildInputs = with qt5; [
    autoreconfHook pkg-config
    wrapQtAppsHook
    qtbase
    qtwebchannel
    qtwebengine
  ];

  buildInputs = with qt5; [
    asciidoctor
    desktop-file-utils
    json_c
    libwebsockets
    openssl
    unixtools.xxd
    zlib
  ];

  configureFlags = [
    "--with-libwebsockets"
    "--with-asciidoctor"
    "--enable-compiled-in-resources"
    "--enable-debug"
    "--with-qt"
  ];

  meta = with lib; {
    homepage = "https://domterm.org/";
    description = "Terminal emulator based on web technologies.";
    license = licenses.bsd3;
  };
}
