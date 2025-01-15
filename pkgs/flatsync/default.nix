{ stdenv, lib, fetchFromGitLab, rustPlatform, cargo, rustc, meson, ninja
, pkg-config, glib, gobject-introspection, libadwaita, wrapGAppsHook4, openssl
, appstream-glib, desktop-file-utils, blueprint-compiler, flatpak }:

stdenv.mkDerivation (finalAttrs: {
  pname = "flatsync";
  version = "unstable-2024-08-16";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "Cogitri";
    repo = "flatsync";
    rev = "4ae868217b00d8c7fc9450cdf41eda8d8303508f";
    hash = "sha256-ATFJv9XtNuIYrz7gbVt1yFM10wNAbOa/cUeDVjSGrGY=";
  };

  strictDeps = true;
  cargoDeps = rustPlatform.fetchCargoTarball {
    name = "${finalAttrs.pname}-${finalAttrs.version}-deps";
    inherit (finalAttrs) src;
    hash = "sha256-qC/kj0eCrSjFmyDwrqtameYRTajnY8HoQaOxME4zWJI=";
  };

  nativeBuildInputs = [
    appstream-glib
    blueprint-compiler
    cargo
    desktop-file-utils
    gobject-introspection
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    rustPlatform.bindgenHook
    rustc
    wrapGAppsHook4
  ];

  buildInputs = [ glib flatpak libadwaita openssl ];

  meta = with lib; {
    homepage = "https://gitlab.gnome.org/Cogitri/flatsync";
    # It has no license yet so technically it's unfree.
    license = licenses.unfree;
    description = "Synchronize your Flatpaks across multiple machines";
    platforms = platforms.linux;
    maintainers = with maintainers; [ foo-dogsquared ];
    mainProgram = "flatsync";
  };
})
