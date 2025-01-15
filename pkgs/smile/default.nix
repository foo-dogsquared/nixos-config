{ stdenv, lib, fetchFromGitHub, meson, ninja, appstream-glib, desktop-file-utils
, gettext, glib, gtk4, libwnck, wrapGAppsHook4, pkg-config, python3Packages
, gobject-introspection }:

python3Packages.buildPythonApplication rec {
  pname = "smile";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "mijorus";
    repo = pname;

    # There's no proper Git tag so we'll have to manually retrieve the commit
    # for now.
    rev = "3ad0888f54bfde67ed6ee3b8335625347b53d460";
    hash = "sha256-PhSiZw/V9DEAa0AYtr0ZIuyrZDZoNN/Ln9Zq+Xl4Vek=";
  };

  format = "other";

  postPatch = ''
    chmod +x ./build-aux/meson/postinstall.py
    patchShebangs ./build-aux/meson/postinstall.py
    substituteInPlace ./build-aux/meson/postinstall.py \
      --replace "gtk-update-icon-cache" "gtk4-update-icon-cache"
  '';

  nativeBuildInputs = [
    gettext
    desktop-file-utils
    appstream-glib
    meson
    ninja
    pkg-config
    glib
    wrapGAppsHook4
  ];

  propagatedNativeBuildInputs = [ gobject-introspection ];

  propagatedBuildInputs = with python3Packages; [
    pygobject3
    manimpango
    dbus-python
  ];

  buildInputs = [ libwnck gtk4 ];

  dontWrapGApps = true;
  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = with lib; {
    homepage = "https://smile.mijorus.it";
    description = "Emoji picker with custom tabs support and localization";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ foo-dogsquared ];
    platforms = platforms.linux;
  };
}
