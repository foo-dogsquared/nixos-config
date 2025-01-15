{ lib, stdenv, fetchFromGitHub, autoreconfHook, desktop-file-utils, pkg-config
, libwebsockets, ncurses, openssl, unixtools, zlib, rustPlatform, perl, qtbase
, qtwebchannel, qtwebengine, wrapQtAppsHook

, withQtDocking ? false

, withKddockwidgets ? false, kddockwidgets

, withAsciidoctor ? true, asciidoctor

, withDocbook ? true, docbook-xsl-ns, libxslt }:

stdenv.mkDerivation rec {
  pname = "domterm";
  version = "unstable-2023-07-22";

  src = fetchFromGitHub {
    owner = "PerBothner";
    repo = "DomTerm";
    rev = "33ca5ad96cd8fc274b8e97533123dd8c33fb1938";
    hash = "sha256-H1Nzqzz7dv4j9hkb08FCExLeq69EkFNXGzhhl/e+uxI=";
  };

  configureFlags =
    [ "--with-libwebsockets" "--enable-compiled-in-resources" "--with-qt" ]
    ++ lib.optional withAsciidoctor "--with-asciidoctor"
    ++ lib.optional withQtDocking "--with-qt-docking"
    ++ lib.optional withKddockwidgets "--with-kddockwidgets"
    ++ lib.optional withDocbook "--with-docbook";

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    wrapQtAppsHook
    qtbase
    qtwebchannel
    qtwebengine
  ];

  buildInputs = [
    asciidoctor
    desktop-file-utils
    ncurses
    libwebsockets
    openssl
    perl
    unixtools.xxd
    zlib
  ] ++ lib.optional withKddockwidgets kddockwidgets
    ++ lib.optional withAsciidoctor asciidoctor
    ++ lib.optionals withDocbook [ docbook-xsl-ns libxslt ];

  meta = with lib; {
    homepage = "https://domterm.org/";
    description = "Terminal emulator based on web technologies.";
    license = licenses.bsd3;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}
