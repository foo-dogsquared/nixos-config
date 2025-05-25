{ lib, stdenvNoCC }:

lib.extendMkDerivation {
  constructDrv = stdenvNoCC.mkDerivation;
  excludeDrvArgNames = [
    "buildDir"
  ];
  extendDrvArgs =
    finalAttrs:
    {
      buildDir ? "_public",
      ...
    }@args:
    {
      buildFlags = args.buildFlags or [ ] ++ [
        "--site-dir" buildDir
      ];

      buildPhase = args.buildPhase or ''
        runHook preBuild

        mkdocs ''${buildFlags[@]}

        runHook postBuild
      '';

      installPhase = args.installPhase or ''
        runHook preInstall

        mkdir -p $out && cp -r ${buildDir}/* $out/

        runHook postInstall
      '';

      dontFixup = args.dontFixup or true;
      doCheck = args.doCheck or true;
    };
}
