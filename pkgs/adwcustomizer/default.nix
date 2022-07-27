{ stdenv, lib, fetchFromGitHub, wrapGAppsHook4, meson, ninja, pkg-config, glib, desktop-file-utils, gettext, blueprint-compiler, python3Packages, appstream-glib, gtk4, libadwaita, libportal, libportal-gtk4 }:

# Not all parts of the application works with the current nixpkgs version of
# libadwaita.
python3Packages.buildPythonApplication rec {
  pname = "adwcustomizer";
  version = "2022-07-19";

  src = fetchFromGitHub {
    owner = "ArtyIF";
    repo = "AdwCustomizer";
    rev = "5a6fa1b2ba63a5a8ac3861f28882c4e62f62b10b";
    sha256 = "sha256-KwvAlcRfilu/rC6e145xMC/6I7OXsZYWlYd0GNZoYDs";
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
    libportal
    libportal-gtk4
  ];

  propagatedBuildInputs = with python3Packages; [
    pygobject3
    anyascii
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
