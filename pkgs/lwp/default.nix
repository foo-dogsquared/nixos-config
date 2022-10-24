{ stdenv
, lib
, fetchFromGitHub
, SDL2
, xorg
, libconfig
}:

stdenv.mkDerivation rec {
  pname = "lwp";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "jszczerbinsky";
    repo = pname;
    rev = version;
    sha256 = "sha256-5/wnPXIfC8jiyjC0/2x/PoBZ1lONcoQ3NWL6uEuqPv8=";
  };

  postPatch = ''
    substituteInPlace default.cfg --replace "/usr/share" "${placeholder "out"}/share"
  '';

  buildPhase = ''
    gcc main.c window.c parser.c debug.c -lSDL2 -lX11
  '';

  installPhase = ''
    install -Dm0755 a.out $out/bin/lwp
    install -Dm0644 default.cfg -t $out/etc
    mkdir -p $out/share/lwp
    cp -R ./wallpapers $out/share/lwp
  '';

  buildInputs = [
    SDL2
    xorg.libX11
    libconfig
  ];

  meta = with lib; {
    homepage = "https://github.com/jszczerbinsky/lwp";
    description = "Parallax wallpaper engine for Linux and Windows";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
