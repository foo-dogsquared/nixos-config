{ stdenv
, lib
, fetchpatch
, fetchFromGitHub
, meson
, ninja
, pkg-config
, makeBinaryWrapper
, lua
, pixman
, wlroots
, wayland
, wayland-protocols
, wayland-scanner
, libxkbcommon
, udev
, git
, extraOptions ? [ ]
}:

let
  rev = "17814972abe6a8811a586fa87c99a2b16a86075f";
in
stdenv.mkDerivation rec {
  pname = "kiwmi";
  version = "2022-09-26";

  src = fetchFromGitHub {
    inherit rev;
    owner = "buffet";
    repo = pname;
    sha256 = "sha256-n9PA6cyEjSlnDcRrqIkO83UaCE/hovbi/oZon1B+nuw=";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/buffet/kiwmi/pull/71.patch";
      hash = "sha256-28/i2fpYD2w9SxtMprT4qOoeCG2CIn31hav07W/oY2o=";
    })
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    makeBinaryWrapper
  ];

  buildInputs = [
    git
    libxkbcommon
    lua
    pixman
    udev
    wayland
    wayland-protocols
    wayland-scanner
    wlroots
  ];

  mesonFlags = [ "-Dkiwmi-version=${version}-${lib.strings.substring 0 6 rev}" ];

  passthru.providedSessions = [ "kiwmi" ];

  postInstall = lib.optionalString (lib.length extraOptions >= 1) ''
    wrapProgram $out/bin/kiwmi \
      ${lib.concatMapStrings (flag: " --add-flags ${lib.escapeShellArg flag}") extraOptions}
  '';

  meta = with lib; {
    homepage = "https://github.com/buffet/kiwmi";
    description = "Fully programmable Wayland compositor";
    license = licenses.mpl20;
    platforms = platforms.unix;
  };
}
