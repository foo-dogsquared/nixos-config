{ lib, callPackage, newScope, python3Packages, ... }:

lib.fix' (self: let
  callPackage = newScope self;
in {
  recurseForDerivations = true;
  attrs-strict = callPackage ./attrs-strict.nix { inherit python3Packages; };
  aiohttp-utils = callPackage ./aiohttp-utils.nix { inherit python3Packages; };

  swh-fuse = callPackage ./swh-fuse.nix { inherit python3Packages; };
  swh-core = callPackage ./swh-core.nix { inherit python3Packages; };
  swh-model = callPackage ./swh-model.nix { inherit python3Packages; };
  swh-web-client = callPackage ./swh-web-client.nix { inherit python3Packages; };
  swh-auth = callPackage ./swh-auth.nix { inherit python3Packages; };
})
