{ stdenv
, lib
, fetchFromGitHub
, wrapGAppsHook4
, meson
, ninja
, pkg-config
, glib
, desktop-file-utils
, gettext
, blueprint-compiler
, python3Packages
, appstream-glib
, gtk4
, libadwaita
, libportal
, libportal-gtk4
, gobject-introspection
}:

# Not all parts of the application works with the current nixpkgs version of
# libadwaita.
python3Packages.buildPythonApplication rec {
  pname = "adwcustomizer";
  version = "2022-08-07";

  src = fetchFromGitHub {
    owner = "ArtyIF";
    repo = "AdwCustomizer";
    rev = "d20bf680672b53f8be0c046b99e704fad29e7b2d";
    sha256 = "sha256-Js6YXPcMOaEOnfAlQ01WKDdOBCcnLOHnznEN8WxIu0s=";
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
    desktop-file-utils
    gettext
    blueprint-compiler
    gtk4
  ];

  propagatedBuildInputs = [
    gobject-introspection
    appstream-glib
    glib
    libadwaita
    libportal
    libportal-gtk4
  ] ++ (with python3Packages; [
    pygobject3
    anyascii
  ]);

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = with lib; {
    homepage = "https://github.com/ArtyIF/AdwCustomizer";
    description = "Customize libadwaita and GTK3 apps (with adw-gtk3)";
    license = licenses.mit;
  };
}
