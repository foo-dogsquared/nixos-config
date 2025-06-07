# The entrypoint for our custom library set.
#
# Take note, this is modularly included as part of the environment so we cannot
# have any functions or references that could make the evaluation go in an
# infinite recursion such as a function that generates a valid nixpkgs module.
# If you have to add those functions, you'll have to add them in configUtils.
{ pkgs }:

let inherit (pkgs) lib;
in pkgs.lib.makeExtensible (self:
  let callLib = file: import file { inherit pkgs lib self; };
  in {
    trivial = callLib ./trivial.nix;
    data = callLib ./data.nix;
    math = callLib ./math.nix;
    xdg = callLib ./xdg.nix;
    sources = callLib ./sources.nix;

    # Just like from its inspiration, this contains Nix-representable data
    # formats and won't have any attributes exported at the top-level.
    formats = callLib ./formats.nix;

    # For future references, these are the only attributes that are going to be
    # exported as part of nixpkgs overlay.
    fetchers = callLib ./fetchers;
    builders = callLib ./builders;

    # foodogsquared's version of a standard environment. Basically just an
    # extended version of nixpkgs' version that went overboard with
    # developer-oriented dependencies.
    stdenv = with pkgs;
      [ direnv cookiecutter oils-for-unix nushell ipcalc ]
      ++ lib.optionals stdenv.isLinux [
        gdb
        moreutils
        meson
        ninja
        pkg-config
        man-pages
        man-pages-posix
        neovim
      ] ++ (import "${pkgs.path}/pkgs/stdenv/generic/common-path.nix" {
        inherit pkgs;
      });

    inherit (self.builders)
      makeXDGMimeAssociationList makeXDGPortalConfiguration makeXDGDesktopEntry
      buildHugoSite buildMdbookSite buildMkdocsSite buildAntoraSite buildFDSEnv
      buildDconfDb buildDconfProfile buildDconfConf buildDconfPackage
      buildDockerImage;
    inherit (self.trivial)
      countAttrs filterAttrs' bitsToBytes SIPrefixExponent
      metricPrefixMultiplier binaryPrefixExponent binaryPrefixMultiplier
      parseBytesSizeIntoInt unitsToInt genAttrs';
    inherit (self.data) importYAML renderTeraTemplate renderMustacheTemplate;
    inherit (self.fetchers) fetchInternetArchive fetchUgeeDriver
      fetchWebsiteIcon fetchPexelImages fetchPexelVideos fetchUnsplashImages;
    inherit (self.xdg) getXdgDesktop getXdgAutostartFile;
  } // lib.optionalAttrs (builtins ? fetchTree) {
    flake = callLib ./flake.nix;

    inherit (self.flake) importFlakeMetadata fetchTree fetchInput;
  })
