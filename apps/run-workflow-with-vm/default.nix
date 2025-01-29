{ stdenv, lib, meson, ninja, inputs ? [ ] }:

stdenv.mkDerivation (finalAttrs: {
  pname = "run-workflow-with-vm";
  version = "2024-05-17";

  src = ./.;

  nativeBuildInputs = [ meson ninja ];

  preConfigure = ''
    mesonFlagsArray+=("-Dinputs=[${lib.concatStringsSep "," inputs}]")
  '';

  meta = with lib; {
    description = "Quickly run workflow modules with a VM.";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    mainProgram = finalAttrs.pname;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
})
