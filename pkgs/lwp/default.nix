{ stdenv
, lib
, fetchFromGitHub
, SDL2
, xorg
}:

stdenv.mkDerivation rec {
  pname = "lwp";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "jszczerbinsky";
    repo = pname;
    rev = version;
    sha256 = "sha256-VwWPP71kAVxM8+GR0Z/RSshtoK7KNzRgSkdOBXOVZ9s=";
  };

  installPhase = ''
    install -Dm0755 a.out $out/bin/lwp
    mkdir -p $out/share/lwp
    cp -R ./wallpapers $out/share/lwp
  '';

  buildInputs = [
    SDL2
    xorg.libX11
  ];

  meta = with lib; {
    homepage = "https://github.com/jszczerbinsky/lwp";
    description = "Parallax wallpaper engine for Linux and Windows";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
