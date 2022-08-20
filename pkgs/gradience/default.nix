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
, gtk4
, libadwaita
, libportal
, libportal-gtk4
, gobject-introspection
, python-material-color-utilities
}:

# Not all parts of the application works with the current nixpkgs version of
# libadwaita.
python3Packages.buildPythonApplication rec {
  pname = "adwcustomizer";
  version = "unstable-2022-08-20";

  src = fetchFromGitHub {
    owner = "AdwCustomizerTeam";
    repo = "AdwCustomizer";
    rev = "4ad3759a3cd7e034cd6c23fd5bfd2c2e1f3623ef";
    sha256 = "sha256-Z6fYAXr5HEoLxmlGfLToF7WXPoJGaQmLQHH7oG333Wo=";
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
    gtk4
    libadwaita
    libportal
    libportal-gtk4
    librsvg
  ];

  propagatedBuildInputs = with python3Packages; [
    pygobject3
    anyascii
    pip
  ] ++ [
    python-material-color-utilities
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = with lib; {
    homepage = "https://github.com/AdwCustomizerTeam/AdwCustomizer";
    description = "Customize libadwaita and GTK3 apps (with adw-gtk3)";
    license = licenses.mit;
  };
}
