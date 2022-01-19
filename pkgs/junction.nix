{ lib, stdenv, fetchFromGitHub, desktop-file-utils, gjs, appstream-glib
, gobject-introspection, gsettings-desktop-schemas, libadwaita, meson_0_60
, ninja, wrapGAppsHook4 }:

stdenv.mkDerivation rec {
  pname = "junction";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "sonnyp";
    repo = "Junction";
    rev = "v${version}";
    sha256 = "sha256-lU6dGsX6jYYmwRz0z4V+4xTFAikUYCsszNVoyc7snwM=";
  };

  nativeBuildInputs = [
    meson_0_60
    ninja
    wrapGAppsHook4
    gobject-introspection
    appstream-glib
    desktop-file-utils
  ];

  buildInputs = [ libadwaita gjs gsettings-desktop-schemas ];

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
