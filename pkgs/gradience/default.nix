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
, librsvg
, blueprint-compiler
, python3Packages
, appstream-glib
, libadwaita
, libportal
, libportal-gtk4
, gobject-introspection
, python-material-color-utilities
}:

# Not all parts of the application works with the current nixpkgs version of
# libadwaita.
python3Packages.buildPythonApplication rec {
  pname = "gradience";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "GradienceTeam";
    repo = "Gradience";
    rev = version;
    sha256 = "sha256-0LIkYgNSgB91ihIw96ss4dgvQZ1z17iU8oyvJpBMCQQ=";
  };

  format = "other";
  dontWrapGApps = true;

  nativeBuildInputs = [
    appstream-glib
    blueprint-compiler
    desktop-file-utils
    gettext
    glib
    gobject-introspection
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    libadwaita
    libportal
    libportal-gtk4
    librsvg
  ];

  propagatedBuildInputs = with python3Packages; [
    anyascii
    pluggy
    pygobject3
    requests
    svglib
    urllib3
  ] ++ [
    python-material-color-utilities
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = with lib; {
    homepage = "https://github.com/GradienceTeam/Gradience";
    description = "Customize libadwaita and GTK3 apps (with adw-gtk3)";
    license = licenses.mit;
  };
}
