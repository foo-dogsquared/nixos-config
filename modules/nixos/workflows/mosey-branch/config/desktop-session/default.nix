{ stdenv
, lib
, meson
, ninja
, pkg-config
, makeWrapper
, gnome

# This is the prefix used for the installed files in the output.
, prefix ? "one.foodogsquared.MoseyBranch."
, serviceScript ? "Hyprland"

, agsScript ? "ags"
, polkitScript ? "polkit"
}:

stdenv.mkDerivation rec {
  pname = "mosey-branch-custom-desktop-session";
  version = "2023-08-21";

  src = ./.;
  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    makeWrapper
  ];

  mesonFlags = [
    "-Dservice_script=${serviceScript}"
    "-Dags_script=${agsScript}"
    "-Dpolkit_script=${polkitScript}"
  ];

  passthru.providedSessions = [ "mosey-branch" ];

  postInstall = ''
    wrapProgram "$out/libexec/mosey-branch-session" \
      --prefix PATH : "${lib.makeBinPath [ gnome.gnome-session ]}"
  '';

  meta = with lib; {
    description = "Custom desktop files for the custom desktop environment";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
