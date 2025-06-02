{ lib, stdenv, fetchNpmDeps, cacert, antora, npmHooks, nodejs }:

lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;
  excludeDrvArgNames = [
    "buildDir"
    "playbookFile"
  ];
  extendDrvArgs =
    finalAttrs:
    {
      # The hash of the fixed-output derivation from the NPM package lock. If
      # not set to null (i.e., set to an empty string), the builder assumes the
      # source uses an NPM-based setup with package.json and package-lock.json
      # located somewhere in the source. Otherwise, it will skip all of that
      # and use nixpkgs' version of Antora instead.
      modHash ? null,

      # The root directory of where the package.json and its company. By
      # default, it assumes it's in the source.
      modRoot ? null,

      # The build directory of the site. This is enforced by the builder to
      # have smoother operations between the default phases.
      buildDir ? "build/site",

      # The relative path of the playbook file.
      playbookFile ? "antora-playbook.yml",

      # Derivation containing the UI bundle of the playbook. This is
      # practically required as Antora will make a network requests anyways
      # unless the `--ui-bundle` flag is given.
      uiBundle ? null,

      # An override function for the NPM module fetcher.
      overrideModAttrs ? (_: _: { }),
      ...
    }
    @args:
    lib.optionalAttrs (modHash != null) {
      npmDeps = (fetchNpmDeps {
        inherit (finalAttrs) version;
        src = finalAttrs.modRoot or finalAttrs.src;
        pname = "${finalAttrs.pname}-${finalAttrs.version}-npm-modules";
        hash = modHash;
      }).overrideAttrs (finalAttrs.passthru.overrideModAttrs or overrideModAttrs);
    }
    // {
      dontFixup = args.dontFixup or true;
      doCheck = args.doCheck or true;

      impureEnvVars = args.impureEnvVars or [] ++ lib.fetchers.proxyImpureEnvVars;

      nativeBuildInputs = args.nativeBuildInputs or [ ] ++ [
        cacert
      ] ++ lib.optionals (modHash != null) [
        npmHooks.npmConfigHook
        nodejs
      ] ++ lib.optionals (modHash == null) [ antora ];

      buildInputs =
        args.buildInputs or [ ]
        ++ lib.optionals (modHash != null) [ nodejs ];

      strictDeps = true;

      buildFlags =
        lib.optionals (playbookFile != "") [ playbookFile ]
        ++ lib.optionals (buildDir != "") [ "--to-dir" buildDir ]
        ++ lib.optionals (uiBundle != null) [ "--ui-bundle-url" uiBundle ];

      postPatch =
        lib.optionalString (finalAttrs.modRoot or null != null) ''
          cp "${finalAttrs.modRoot}/package.json" ./package.json
          cp "${finalAttrs.modRoot}/package-lock.json" ./package-lock.json
        '';

      buildPhase = args.buildPhase or ''
        runHook preBuild

        ${lib.optionalString (finalAttrs.npmDeps or null != null) ''
          export PATH=node_modules/.bin''${PATH:+":$PATH"}
        ''}
        antora generate ''${buildFlags[@]}

        runHook postBuild
      '';

      installPhase = args.installPhase or ''
        runHook preInstall

        mkdir -p $out && cp -r ${lib.escapeShellArg buildDir}/* $out

        runHook postInstall
      '';

      passthru = args.passthru or { }
        // lib.optionalAttrs (uiBundle != null) { inherit uiBundle; };
    };
}
