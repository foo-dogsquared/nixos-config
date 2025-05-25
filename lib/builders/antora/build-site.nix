{ lib, foodogsquaredLib, stdenv, fetchNpmDeps, cacert, npmHooks, nodejs }:

lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;
  excludeDrvArgNames = [
    "buildDir"
    "playbookFile"
  ];
  extendDrvArgs =
    finalAttrs:
    {
      vendorHash ? null,

      npmRoot ? "./",

      buildDir ? "build/site",

      playbookFile ? "antora-playbook.yml",

      ...
    }
    @args:
    lib.optionalAttrs (vendorHash != null) {
      inherit npmRoot;

      npmDeps = fetchNpmDeps {
        inherit (finalAttrs) version src;
        pname = "${finalAttrs.pname}-${finalAttrs.version}-npm-modules";
        sourceRoot = finalAttrs.sourceRoot or "./";
        hash = args.vendorHash;
      };
    }
    // {
      dontFixup = args.dontFixup or true;
      doCheck = args.doCheck or true;

      impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ foodogsquaredLib.fetchers.gitImpureEnvVars;

      nativeBuildInputs = args.nativeBuildInputs or [ ] ++ [
        cacert
      ] ++ lib.optionals (vendorHash != null) [
        npmHooks.npmConfigHook
        nodejs
      ];
      buildInputs =
        args.buildInputs or [ ]
        ++ lib.optionals (vendorHash != null) [ nodejs ];

      strictDeps = true;

      buildFlags =
        lib.optionals (playbookFile != "") [ playbookFile ]
        ++ lib.optionals (buildDir != "") [ "--to-dir" buildDir ];

      buildPhase = args.buildPhase or ''
        runHook preBuild

        antora generate ''${buildFlags[@]}

        runHook postBuild
      '';

      installPhase = args.installPhase or ''
        runHook preInstall

        mkdir -p $out && cp -r ${lib.escapeShellArg buildDir}/* $out

        runHook postInstall
      '';
    };
}
