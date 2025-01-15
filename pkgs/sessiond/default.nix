{ lib, fetchFromGitHub, fetchpatch, meson, ninja, pkg-config, coreutils, glib
, gobject-introspection, xorg, udev, wireplumber, pipewire, perl
, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "sessiond";
  version = "0.6.1";
  format = "other";

  src = fetchFromGitHub {
    owner = "jcrd";
    repo = "sessiond";
    rev = "v${version}";
    hash = "sha256-w1IOzhZAlWiYaGBdS2CTa2Z8fHXcsAvBKIoXLQSBjts=";
  };

  patches = [
    (fetchpatch {
      url =
        "https://github.com/jcrd/sessiond/commit/217ed63e2033c46c637e0564ef44ceaedff3e102.patch";
      hash = "sha256-/GFPwJ4OBskavUJYhR5LGpt+HZABDOCpx6cVYDCYTNE=";
    })

    ./0002-meson-Add-python-sessiond-installation.patch
  ];

  nativeBuildInputs =
    [ meson ninja pkg-config glib gobject-introspection perl ];

  buildInputs =
    [ udev xorg.libXi xorg.libX11 xorg.libXext wireplumber pipewire ];

  propagatedBuildInputs = with python3Packages; [ dbus-python ];

  postPatch = ''
    substituteInPlace ./systemd/sessiond.service \
      --replace '/usr/bin/kill' '${lib.getExe' coreutils "kill"}' \
      --replace '/usr/bin' "${placeholder "out"}/bin"
  '';

  meta = with lib; {
    homepage = "https://github.com/jcrd/sessiond";
    description = "Standalone session manager for X11 window managers";
    license = licenses.gpl3Plus;
    mainProgram = "sessiond";
    maintainers = with maintainers; [ foo-dogsquared ];
    platforms = platforms.linux;
  };
}
