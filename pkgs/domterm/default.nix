{ lib, stdenv, fetchFromGitHub, autoreconfHook, desktop-file-utils, pkg-config
, libwebsockets, json_c, openssl, asciidoctor, unixtools, zlib,

# For including Java classes. Take note it doesn't compile them properly and it
# still builds successfully so including them is disabled by default.
openjdk,

# For Qt backend which is included by default.
qt5,

enableQt ? true, enableJava ? false }:

# TODO: Compile with the experimental wry backend.
# * Wait until gdk-pixbuf is >=3.0.
stdenv.mkDerivation rec {
  pname = "domterm";
  version = "unstable-2022-07-08";

  src = fetchFromGitHub {
    owner = "PerBothner";
    repo = "DomTerm";
    rev = "b063ddcf9acc6dbeaaca42bc2caa1c86d2e11805";
    sha256 = "sha256-bXxV6uG61ZX8Tgm2KrXooblLX/4TNPXJd06bnvpWU50=";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config ]
    ++ lib.optional enableQt qt5.wrapQtAppsHook;

  buildInputs = [
    asciidoctor
    desktop-file-utils
    json_c
    libwebsockets
    openssl
    unixtools.xxd
    zlib
  ] ++ lib.optionals enableQt (with qt5; [ qtbase qtwebengine qtwebchannel ])
    ++ lib.optional enableJava openjdk;

  configureFlags = [
    "--disable-java-pty"
    "--with-libwebsockets"

    # Until the dependencies are updated (e.g., `gdk-pixbuf >= 3.0`), this is
    # going to be painful to build.
    "--without-wry"
  ] ++ lib.optional enableJava "--with-java"
    ++ lib.optional enableQt "--with-qt";

  # Force Java to take input as UTF-8 instead of ASCII.
  JAVA_TOOL_OPTIONS = "-Dfile.encoding=UTF8";

  meta = with lib; {
    homepage = "https://domterm.org/";
    description = "Terminal emulator based on web technologies.";
    license = licenses.bsd3;
  };
}
