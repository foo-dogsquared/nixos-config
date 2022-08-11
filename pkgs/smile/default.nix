{ stdenv
, lib
, fetchFromGitHub
, meson
, ninja
, appstream-glib
, desktop-file-utils
, gettext
, glib
, gtk4
, libwnck3
, wrapGAppsHook4
, pkg-config
, python3Packages
, gobject-introspection
}:

python3Packages.buildPythonApplication rec {
  pname = "smile";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "mijorus";
    repo = pname;
    rev = version;
    sha256 = "sha256-F1ZDwCvhLMcqqtfneN12IMslhA2E54Oxcnaqy+AdMXI=";
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

  propagatedNativeBuildInputs = [
    gobject-introspection
  ];

  propagatedBuildInputs = with python3Packages; [
    pygobject3
    manimpango
  ];

  buildInputs = [
    libwnck3
    gtk4
  ];

  dontWrapGApps = true;
  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = with lib; {
    homepage = "https://github.com/mijorus/smile";
    description = "Emoji picker with custom tabs support.";
    license = licenses.gpl3Only;
  };
}
