{ stdenv
, lib
, meson
, ninja
, nix
, makeWrapper
, inputs ? [ ]
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "run-workflow-with-vm";
  version = "2024-05-17";

  src = ./.;

  nativeBuildInputs = [
    meson
    ninja
    makeWrapper
  ];

  preConfigure = ''
    mesonFlagsArray+=("-Dinputs=[${lib.concatStringsSep "," inputs}]")
  '';

  postInstall = ''
    wrapProgram $out/bin/${finalAttrs.pname} \
      --prefix PATH ':' '${lib.makeBinPath [ nix ]}'
  '';

  meta = with lib; {
    description = "Quickly run workflow modules with a VM.";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    mainProgram = finalAttrs.pname;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
})
