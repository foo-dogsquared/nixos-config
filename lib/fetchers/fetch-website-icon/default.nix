{ lib, callPackage, stdenv, cacert }:

let
  extractWebsiteIcon = callPackage ./package/package.nix { };
in
lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;
  excludeDrvArgNames = [
    "url"
    "size"
  ];
  extendDrvArgs =
    finalAttrs:
    {
      # The URL of the website.
      url,

      # The size of the (square) image.
      size ? 192,

      # The hash representing the website files to be downloaded.
      hash,

      # A set of command line arguments to be included
      cliFlags ? [ ],

      ...
    }@args:
    {
      enableParallelBuilding = true;
      name = args.name or "fetch-website-icon";
      nativeBuildInputs = [ cacert ];
      buildInputs = [ extractWebsiteIcon ];
      cliFlags = cliFlags ++ [
        "--url" url
        "--largest-only"
        "--output-dir" "icons"
        "--size" size
      ];

      impureEnvVars = lib.fetchers.proxyImpureEnvVars;

      buildCommand = ''
        mkdir -p icons && extract-website-icon ''${cliFlags[@]}
        mv icons/* $out
      '';

      outputHashMode = "recursive";
      outputHash = args.hash;
      outputHashAlgo = if args.hash == "" then "sha512" else null;
    };
  }
