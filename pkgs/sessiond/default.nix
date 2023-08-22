{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, meson
, ninja
, pkg-config
, glib
, xorg
, udev
, wireplumber
, pipewire
, perl
}:

stdenv.mkDerivation rec {
  pname = "sessiond";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "jcrd";
    repo = "sessiond";
    rev = "v${version}";
    hash = "sha256-w1IOzhZAlWiYaGBdS2CTa2Z8fHXcsAvBKIoXLQSBjts=";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/jcrd/sessiond/pull/8.patch";
      hash = "sha256-/GFPwJ4OBskavUJYhR5LGpt+HZABDOCpx6cVYDCYTNE=";
    })
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    glib
    udev
    xorg.libXi
    xorg.libX11
    xorg.libXext
    wireplumber
    pipewire
    perl
  ];

  meta = with lib; {
    homepage = "https://github.com/jcrd/sessiond";
    description = "Standalone session manager for X11 window managers";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
