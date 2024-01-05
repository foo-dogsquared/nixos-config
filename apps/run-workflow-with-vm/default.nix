{ stdenv
, lib
, meson
, ninja
, makeWrapper
, inputs ? []
}:

stdenv.mkDerivation {
  pname = "run-workflow-with-vm";
  version = "2024-01-05";

  src = ./.;

  nativeBuildInputs = [
    meson
    ninja
    makeWrapper
  ];

  preConfigure = ''
    mesonFlagsArray+=("-Dinputs=[${lib.concatStringsSep "," inputs}]")
  '';

  meta = with lib; {
    description = "Quickly run workflow modules with a VM.";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
