# Bahaghari's subproject.
{ ... }:

{
  flake = {
    nixosModules = {
      "bahaghari/tinted-theming" = ../../subprojects/bahaghari/modules/tinted-theming;
    };

    homeModules = {
      "bahaghari/tinted-theming" = ../../subprojects/bahaghari/modules/tinted-theming;
    };

    nixvimModules = {
      "bahaghari/tinted-theming" = ../../subprojects/bahaghari/modules/tinted-theming;
    };

    bahaghariLib = ../../subprojects/bahaghari/lib;
  };
}
