{ lib, callPackage, stdenv, cacert, pkg-config, makeFontsCache, fontconfig, noto-fonts, noto-fonts-emoji }:

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
      buildFlags ? [ ],

      # A list of fonts to be included within the environment. This is mainly
      # used for the backup icon generation in the program which uses
      # fontconfig utilities to access the fonts.
      fonts ? [ noto-fonts noto-fonts-emoji ],

      ...
    }@args:
    let
      cacheConf = makeFontsCache {
        inherit fontconfig;
        fontsDirectories = fonts;
      };
    in
    {
      passAsFile = [ "fonts" ];

      enableParallelBuilding = true;
      name = args.name or "fetch-website-icon";
      nativeBuildInputs = [ pkg-config cacert ];
      buildInputs = [ fontconfig extractWebsiteIcon ];
      buildFlags = buildFlags ++ [
        "--url" url
        "--largest-only"
        "--output-dir" "icons"
        "--size" size
      ];

      impureEnvVars = lib.fetchers.proxyImpureEnvVars;

      buildCommand = ''
        export $FONTCONFIG_FILE=${cacheConf}
        extract-website-icon ''${buildFlags[@]}
        mv ./icon $out
      '';

      outputHashMode = "recursive";
      outputHash = args.hash;
      outputHashAlgo = if args.hash == "" then "sha512" else null;
    };
  }
