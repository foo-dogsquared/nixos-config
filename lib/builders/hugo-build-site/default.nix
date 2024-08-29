{
  hugo,
  go,
  cacert,
  git,
  lib,
  stdenv,
}:

# A modified Go builder for generating a website with Hugo. Since it relies on
# Hugo modules (which is basically wrapper around Go modules), this can be used
# for Hugo projects that heavily uses them.
#
# Take note, this doesn't work for Hugo projects with remote resources
# right in the content since Hugo allows network access when generating
# the website.
{
  name ? "${args'.pname}-${args'.version}",

  nativeBuildInputs ? [ ],
  passthru ? { },

  # A function to override the goModules derivation
  overrideModAttrs ? (_oldAttrs: { }),

  # path to go.mod and go.sum directory
  modRoot ? "./",

  # vendorHash is the SRI hash of the vendored dependencies
  #
  # if vendorHash is null, then we won't fetch any dependencies and
  # rely on the vendor folder within the source.
  vendorHash ? throw (
    if args' ? vendorSha256 then
      "buildGoModule: Expect vendorHash instead of vendorSha256"
    else
      "buildGoModule: vendorHash is missing"
  ),

  # Whether to delete the vendor folder supplied with the source.
  deleteVendor ? false,

  # Whether to fetch (go mod download) and proxy the vendor directory.
  # This is useful if your code depends on c code and go mod tidy does not
  # include the needed sources to build or if any dependency has case-insensitive
  # conflicts which will produce platform dependant `vendorHash` checksums.
  proxyVendor ? false,

  # We want parallel builds by default
  enableParallelBuilding ? true,

  # Do not enable this without good reason
  # IE: programs coupled with the compiler
  allowGoReference ? false,

  CGO_ENABLED ? go.CGO_ENABLED,

  meta ? { },

  ldflags ? [ ],

  GOFLAGS ? [ ],

  ...
}@args':

let
  args = removeAttrs args' [
    "overrideModAttrs"
    "vendorSha256"
    "vendorHash"
  ];

  GO111MODULE = "on";
  GOTOOLCHAIN = "local";

  hugoModules =
    if (vendorHash == null) then
      ""
    else
      (stdenv.mkDerivation {
        name = "${name}-hugo-modules";

        nativeBuildInputs = (args.nativeBuildInputs or [ ]) ++ [
          hugo
          go
          git
          cacert
        ];

        inherit (args) src;
        inherit (go) GOOS GOARCH;
        inherit GO111MODULE GOTOOLCHAIN;

        # The following inheritence behavior is not trivial to expect, and some may
        # argue it's not ideal. Changing it may break vendor hashes in Nixpkgs and
        # out in the wild. In anycase, it's documented in:
        # doc/languages-frameworks/go.section.md
        prePatch = args.prePatch or "";
        patches = args.patches or [ ];
        patchFlags = args.patchFlags or [ ];
        postPatch = args.postPatch or "";
        preBuild = args.preBuild or "";
        postBuild = args.modPostBuild or "";
        sourceRoot = args.sourceRoot or "";
        setSourceRoot = args.setSourceRoot or "";
        env = args.env or { };

        impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
          "GIT_PROXY_COMMAND"
          "SOCKS_SERVER"
          "GOPROXY"
        ];

        configurePhase =
          args.modConfigurePhase or ''
            runHook preConfigure
            export GOCACHE=$TMPDIR/go-cache
            export GOPATH="$TMPDIR/go"
            cd "${modRoot}"
            runHook postConfigure
          '';

        buildPhase =
          args.modBuildPhase or (
            ''
              runHook preBuild
            ''
            + lib.optionalString deleteVendor ''
              if [ ! -d _vendor ]; then
                echo "_vendor folder does not exist, 'deleteVendor' is not needed"
                exit 10
              else
                rm -rf _vendor
              fi
            ''
            + ''
              if [ -d _vendor ]; then
                echo "_vendor folder exists, please set 'vendorHash = null;' in your expression"
                exit 10
              fi

              ${
                if proxyVendor then
                  ''
                    mkdir -p "''${GOPATH}/pkg/mod/cache/download"
                    hugo mod vendor
                  ''
                else
                  ''
                    if (( "''${NIX_DEBUG:-0}" >= 1 )); then
                      hugoModVendorFlags+=(-v)
                    fi
                    hugo mod vendor "''${hugoModVendorFlags[@]}"
                  ''
              }

              mkdir -p _vendor

              runHook postBuild
            ''
          );

        installPhase =
          args.modInstallPhase or ''
            runHook preInstall

            ${
              if proxyVendor then
                ''
                  rm -rf "''${GOPATH}/pkg/mod/cache/download/sumdb"
                  cp -r --reflink=auto "''${GOPATH}/pkg/mod/cache/download" $out
                ''
              else
                ''
                  cp -r --reflink=auto _vendor $out
                ''
            }

            if ! [ "$(ls -A $out)" ]; then
              echo "_vendor folder is empty, please set 'vendorHash = null;' in your expression"
              exit 10
            fi

            runHook postInstall
          '';

        dontFixup = true;

        outputHashMode = "recursive";
        outputHash = vendorHash;
        # Handle empty vendorHash; avoid
        # error: empty hash requires explicit hash algorithm
        outputHashAlgo = if vendorHash == "" then "sha256" else null;
      }).overrideAttrs
        overrideModAttrs;

  package = stdenv.mkDerivation (
    args
    // {
      nativeBuildInputs = [
        hugo
        git
        go
      ] ++ nativeBuildInputs;

      inherit (go) GOOS GOARCH;

      GOFLAGS =
        GOFLAGS
        ++
          lib.warnIf (lib.any (lib.hasPrefix "-mod=") GOFLAGS)
            "use `proxyVendor` to control Go module/vendor behavior instead of setting `-mod=` in GOFLAGS"
            (lib.optional (!proxyVendor) "-mod=vendor")
        ++
          lib.warnIf (builtins.elem "-trimpath" GOFLAGS)
            "`-trimpath` is added by default to GOFLAGS by buildGoModule when allowGoReference isn't set to true"
            (lib.optional (!allowGoReference) "-trimpath");
      inherit
        CGO_ENABLED
        enableParallelBuilding
        GO111MODULE
        GOTOOLCHAIN
        ;

      # If not set to an explicit value, set the buildid empty for reproducibility.
      ldflags = ldflags ++ lib.optional (!lib.any (lib.hasPrefix "-buildid=") ldflags) "-buildid=";

      configurePhase =
        args.configurePhase or (
          ''
            runHook preConfigure

            export GOCACHE=$TMPDIR/go-cache
            export GOPATH="$TMPDIR/go"
            export GOPROXY=off
            export GOSUMDB=off
            cd "$modRoot"
          ''
          + lib.optionalString (vendorHash != null) ''
            ${
              if proxyVendor then
                ''
                  export GOPROXY=file://${hugoModules}
                ''
              else
                ''
                  rm -rf _vendor
                  cp -r --reflink=auto ${hugoModules} _vendor
                ''
            }
          ''
          + ''

            # currently pie is only enabled by default in pkgsMusl
            # this will respect the `hardening{Disable,Enable}` flags if set
            if [[ $NIX_HARDENING_ENABLE =~ "pie" ]]; then
              export GOFLAGS="-buildmode=pie $GOFLAGS"
            fi

            runHook postConfigure
          ''
        );

      buildPhase =
        args.buildPhase or ''
          runHook preBuild
          hugo "''${buildFlags[@]}" --destination public
          runHook postBuild
        '';

      doCheck = args.doCheck or true;
      checkPhase =
        args.checkPhase or ''
          runHook preCheck

          runHook postCheck
        '';

      installPhase =
        args.installPhase or ''
          runHook preInstall

          mkdir -p $out
          cp -r public/* $out

          runHook postInstall
        '';

      strictDeps = true;

      disallowedReferences = lib.optional (!allowGoReference) go;

      passthru = passthru // {
        inherit
          go
          hugo
          hugoModules
          vendorHash
          ;
      };

      meta = {
        # Add default meta information
        platforms = go.meta.platforms or lib.platforms.all;
      } // meta;
    }
  );
in
package
