{ hugo, go, cacert, gitMinimal, lib, stdenv, }:

let
  vendorDir = "_vendor";
  GO111MODULE = "on";
  GOTOOLCHAIN = "local";
in
lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;
  excludeDrvArgNames = [
    "overrideModAttrs"
  ];
  extendDrvArgs =
    finalAttrs:
    {
      # Indicates the hash of the fixed-output derivation containing the Hugo modules.
      vendorHash ? null,

      # Whether to delete the vendor directory.
      deleteVendor ? false,

      # The directory containing the `go.mod` and `go.sum` files.
      modRoot ? "./",

      # An override function for the Hugo module derivation.
      overrideModAttrs ? (finalAttrs: prevAttrs: { }),

      enableParallelBuilding ? true,

      CGO_ENABLED ? go.CGO_ENABLED,
      ...
    }@args:
    {
      inherit (go) GOOS GOARCH;
      inherit CGO_ENABLED enableParallelBuilding GO111MODULE GOTOOLCHAIN;

      buildInputs = args.buildInputs or [ ] ++ [ go gitMinimal hugo ];

      dontFixup = args.dontFixup or true;
      doCheck = args.doCheck or true;

      hugoModules =
        if (finalAttrs.vendorHash == null) then
          ""
        else
          (stdenv.mkDerivation {
            inherit (finalAttrs) src;
            inherit (go) GOOS GOARCH;
            inherit GO111MODULE GOTOOLCHAIN;

            modRoot = finalAttrs.modRoot or modRoot;

            name = "${finalAttrs.name or "${finalAttrs.pname}-${finalAttrs.version}"}-hugo-modules";

            nativeBuildInputs = finalAttrs.nativeBuildInputs or [ ] ++ [
              cacert
            ];
            buildInputs = finalAttrs.buildInputs or [ ] ++ [
              go
              gitMinimal
              hugo
            ];

            configurePhase =
              args.modConfigurePhase or ''
                runHook preConfigure
                export GOCACHE=$TMPDIR/go-cache
                export GOPATH="$TMPDIR/go"
                cd "$modRoot"
                runHook postConfigure
              '';

            buildPhase =
              args.modBuildPhase or ''
                runHook preBuild

                ${lib.optionalString deleteVendor ''
                  if [ ! -d ${vendorDir} ]; then
                    echo "vendor directory does not exist, `deleteVendor` is not needed"
                    exit 10
                  else
                    rm -rf ${vendorDir}
                  fi
                ''}
                if (( "''${NIX_DEBUG:-0}" >= 1 )); then
                  hugoModVendorFlags+=(-v)
                fi
                hugo mod vendor "''${hugoModVendorFlags[@]}"

                runHook postBuild
              '';

            installPhase = args.modInstallPhase or ''
              runHook preInstall

              cp -r --reflink=auto ${vendorDir} $out
              if ! [ "$(ls -A $out)" ]; then
                echo "vendor folder is empty, please set 'vendorHash = null;' in your expression"
                exit 10
              fi

              runHook postInstall
            '';

            impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
              "GIT_PROXY_COMMAND"
              "SOCKS_SERVER"
              "GO_PROXY"
            ];

            dontFixup = true;

            outputHashMode = "recursive";
            outputHash = finalAttrs.vendorHash;
            outputHashAlgo = if finalAttrs.vendorHash == "" then "sha256" else null;
          }).overrideAttrs (finalAttrs.passthru.overrideModAttrs or overrideModAttrs);

      configurePhase = args.configurePhase or ''
        runHook preConfigure

        rm -rf _vendor
        cp -r --reflink=auto ${finalAttrs.hugoModules} _vendor

        runHook postConfigure
      '';

      buildFlags = args.buildFlags or [ ] ++ [ "--destination" "public" ];
      buildPhase = args.buildPhase or ''
        runHook preBuild

        hugo ''${buildFlags[@]}

        runHook postBuild
      '';

      installPhase = args.installPhase or ''
        runHook preInstall

        mkdir -p $out && cp -r public/* $out

        runHook postInstall
      '';

      passthru =
        args.passthru or { } // {
          inherit hugo go;
          inherit (finalAttrs) hugoModules;
          overrideModAttrs = lib.toExtension overrideModAttrs;
        };
    };
}
