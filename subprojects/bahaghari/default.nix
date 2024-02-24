# This is just kept for future compatiblity in case we require pkgs or something.
{ }:

{
  nixosModules = {
    "bahaghari/tinted-theming" = ./modules/tinted-theming;
  };

  homeModules = {
    "bahaghari/tinted-theming" = ./modules/tinted-theming;
  };

  nixvimModules = {
    "bahaghari/tinted-theming" = ./modules/tinted-theming;
  };

  bahaghariLib = ./lib;
}
