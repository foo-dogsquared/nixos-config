{ stdenv, lib, fetchFromGitHub, wrapGAppsHook4, meson, ninja, pkg-config, glib, desktop-file-utils, gettext, blueprint-compiler, python3Packages, appstream-glib, gtk4, libadwaita }:

# Not all parts of the application works with the current nixpkgs version of
# libadwaita.
python3Packages.buildPythonApplication rec {
  pname = "adwcustomizer";
  version = "2022-07-19";

  src = fetchFromGitHub {
    owner = "ArtyIF";
    repo = "AdwCustomizer";
    rev = "718f2490c95de60e8571b1a9d92af78919c14de1";
    sha256 = "sha256-rMaWIJBQ+HC1Gs5xCRyuOCvB2XcTFB2q194bfK5Q48Q=";
  };

  patches = [
    ./patches/update-non-flatpak-env.patch
  ];

  format = "other";
  dontWrapGApps = true;

  nativeBuildInputs = [
    wrapGAppsHook4
    meson
    ninja
    pkg-config
    glib
    desktop-file-utils
    gettext
    appstream-glib
    blueprint-compiler
    gtk4
    libadwaita
  ];

  propagatedBuildInputs = with python3Packages; [
    pygobject3
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = with lib; {
    homepage = "https://github.com/ArtyIF/AdwCustomizer";
    description = "Customize libadwaita and GTK3 apps (with adw-gtk3)";
    license = licenses.mit;
  };
}
