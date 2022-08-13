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
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "AdwCustomizerTeam";
    repo = "AdwCustomizer";
    rev = version;
    sha256 = "sha256-3VHGk27MIgu+15OQeEmX8zfTCj/TtFtVv3Cf/iXxb/c=";
  };

  patches = [
    ./patches/update-non-flatpak-env.patch
  ];

  format = "other";
  dontWrapGApps = true;

  postInstall = ''
    python -m pip install $src/monet/*.whl --no-cache --no-index --no-warn-script-location --prefix="$out" $pipInstallFlags
  '';

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

  propagatedNativeBuildInputs = [
    gobject-introspection
    appstream-glib
    glib
  ];

  propagatedBuildInputs = [
    libadwaita
    libportal
    libportal-gtk4
  ] ++ (with python3Packages; [
    pygobject3
    anyascii
    pillow
    pip
    regex
  ]);

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = with lib; {
    homepage = "https://github.com/AdwCustomizerTeam/AdwCustomizer";
    description = "Customize libadwaita and GTK3 apps (with adw-gtk3)";
    license = licenses.mit;
  };
}
