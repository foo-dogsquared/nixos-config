{ stdenv
, lib
, fetchFromGitHub
, gtk4
, wrapGAppsHook4
, meson
, ninja
, rustPlatform
, libadwaita
, gobject-introspection
, sqlite
, desktop-file-utils
, glib
, pkg-config
, dbus
, appstream-glib
, python3
, gettext
}:

stdenv.mkDerivation rec {
  pname = "furtherance";
  version = "1.5.3";

  src = fetchFromGitHub {
    owner = "lakoliu";
    repo = "Furtherance";
    rev = "v${version}";
    sha256 = "sha256-GKak1P5QX9Y7bXD3E+QPCbi1Auv1mgSYKgbLz7kc3NQ=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    sha256 = "sha256-priZzcuWmII33VQpn7d/tDCNZeF2mj02b5OhdxcU7tc";
  };

  nativeBuildInputs = [
    appstream-glib
    gettext
    meson
    ninja
    rustPlatform.cargoSetupHook
    rustPlatform.rust.cargo
    rustPlatform.rust.rustc
    wrapGAppsHook4
    glib
    pkg-config
  ];

  buildInputs = [
    dbus
    desktop-file-utils
    libadwaita
    gobject-introspection
    gtk4
    python3
    sqlite
  ];

  postPatch = ''
    chmod +x ./build-aux/meson/postinstall.py
    patchShebangs ./build-aux/meson/postinstall.py
    substituteInPlace ./build-aux/meson/postinstall.py \
      --replace "gtk-update-icon-cache" "gtk4-update-icon-cache"
  '';

  meta = with lib; {
    homepage = "https://github.com/lakoliu/Furtherance";
    description = "Private time tracking app";
    license = licenses.gpl3Only;
  };
}
