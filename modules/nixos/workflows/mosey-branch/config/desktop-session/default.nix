{ stdenv
, lib
, meson
, ninja
, pkg-config

# This is the prefix used for the installed files in the output.
, prefix ? "one.foodogsquared.MoseyBranch"
, serviceScript ? "Hyprland"
, sessionScript ? "gnome-session --session=mosey-branch"

, agsScript ? "ags"
, polkitScript ? "polkit"
, ibusScript ? "ibus start"
}:

stdenv.mkDerivation rec {
  pname = "mosey-branch-custom-desktop-session";
  version = "2023-08-13";

  src = ./.;
  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  mesonFlags = [
    "-Dsession_script=${sessionScript}"
    "-Dservice_script=${serviceScript}"
    "-Dags_script=${agsScript}"
    "-Dibus_script=${ibusScript}"
    "-Dpolkit_script=${polkitScript}"
  ];

  passthru.providedSessions = [ "mosey-branch" ];

  meta = with lib; {
    description = "Custom desktop files for the custom desktop environment";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
