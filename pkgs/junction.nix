{ lib, stdenv, fetchFromGitHub, desktop-file-utils, gjs, appstream-glib
, gobject-introspection, gsettings-desktop-schemas, libadwaita, meson
, ninja, wrapGAppsHook4, glib, libportal }:

stdenv.mkDerivation rec {
  pname = "junction";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "sonnyp";
    repo = "Junction";
    rev = "v${version}";
    sha256 = "sha256-jS4SHh1BB8jk/4EP070X44C4n3GjyCz8ozgK8v5lbqc=";
  };

  nativeBuildInputs = [
    meson
    ninja
    wrapGAppsHook4
    desktop-file-utils
  ];

  buildInputs = [ gsettings-desktop-schemas ];

  propagatedBuildInputs = [
    appstream-glib
    gjs
    gobject-introspection
    libadwaita
    glib
    libportal
  ];

  preFixup = ''
    substituteInPlace $out/bin/re.sonny.Junction --replace "#!/usr/bin/env -S gjs" "#!${gjs}/bin/gjs"
  '';

  meta = with lib; {
    homepage = "https://github.com/sonnyp/Junction";
    description = "Application chooser";
    license = licenses.gpl3;
    mainProgram = "re.sonny.Junction";
  };
}
