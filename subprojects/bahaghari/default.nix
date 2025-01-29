# The user entrypoint for Bahaghari. Basically, the most important piece to
# maintain. Just keep in mind we shouldn't have anything requiring from the
# npins sources in here.
#
# This is just kept for future compatiblity in case we require pkgs or something.
{ }:

{
  nixosModules = rec {
    bahaghari = ./modules;
    default = bahaghari;
  };

  homeModules = rec {
    bahaghari = ./modules;
    default = bahaghari;
  };

  nixvimModules = rec {
    bahaghari = ./modules;
    default = bahaghari;
  };

  bahaghariLib = ./lib;
}
