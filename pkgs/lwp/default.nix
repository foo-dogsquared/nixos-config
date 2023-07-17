{ stdenv
, lib
, fetchFromGitHub
, cmake
, SDL2
, xorg
, xwayland
, libconfig
}:

stdenv.mkDerivation rec {
  pname = "lwp";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "jszczerbinsky";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-cy5ZnkC/KtZsjFLAtWjfWL4gacQpEhNv0VC/hbw0LFA=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [
    SDL2
    xorg.libX11
    xwayland
    libconfig
  ];

  # TODO: Add conditional for Mac systems.
  postPatch = ''
    substituteInPlace default.cfg \
      --replace "/usr/share" "${placeholder "out"}/share" \
      --replace "/usr/local" "${placeholder "out"}"
    substituteInPlace CMakeLists.txt \
      --replace "usr/local" "${placeholder "out"}"
  '';

  cmakeFlags = [
    "-DPROGRAM_VERSION=${version}"
  ];

  meta = with lib; {
    homepage = "https://github.com/jszczerbinsky/lwp";
    description = "Parallax wallpaper engine for Linux and Windows";
    license = licenses.mit;

    # We'll package it for Linux only for now.
    platforms = platforms.linux;

    maintainers = with maintainers; [ foo-dogsquared ];
  };
}
