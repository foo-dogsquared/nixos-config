{ stdenv, lib, fetchFromGitHub, python3Packages, gtk3, glib
, gobject-introspection, wrapGAppsHook, webkitgtk }:

python3Packages.buildPythonApplication rec {
  pname = "devdocs-desktop";
  version = "unstable-2022-01-31";

  src = fetchFromGitHub {
    owner = "hardpixel";
    repo = pname;
    rev = "d4164de2773a3c51da0dc271720faf2c8c1e72c4";
    sha256 = "sha256-JeeUbCzfP6R0fHDePsKTRvVQk6GsacsqQbf6BpIP2AY=";
  };

  format = "other";

  propagatedBuildInputs = with python3Packages; [ dbus-python pygobject3 ];

  nativeBuildInputs = [ wrapGAppsHook gobject-introspection ];
  buildInputs = [ glib gtk3 webkitgtk ];

  dontConfigure = true;
  strictDeps = false;

  postPatch = ''
    substituteInPlace devdocs_desktop.py \
      --replace "styles/webview.css" "$out/share/${pname}/styles/webview.css" \
      --replace "scripts/webview.js" "$out/share/${pname}/scripts/webview.js" \
      --replace "ui/main.ui" "$out/share/${pname}/ui/main.ui"
  '';

  installPhase = ''
    install -Dm755 devdocs_desktop.py -t $out/bin
    install -Dm644 icons/hicolor/scalable/* -t $out/share/icons/hicolor/scalable
    install -Dm644 icons/hicolor/symbolic/* -t $out/share/icons/hicolor/symbolic
    install -Dm644 scripts/* -t $out/share/${pname}/scripts
    install -Dm644 styles/* -t $out/share/${pname}/styles
    install -Dm644 ui/* -t $out/share/${pname}/ui
    install -Dm644 devdocs-desktop.desktop -t $out/share/applications
  '';

  meta = with lib; {
    homepage = "https://github.com/hardpixel/devdocs-desktop";
    description = "Desktop application for browsing Devdocs";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
