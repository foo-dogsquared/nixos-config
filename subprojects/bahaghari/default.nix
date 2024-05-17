# This is just kept for future compatiblity in case we require pkgs or something.
{}:

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
