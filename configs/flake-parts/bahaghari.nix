# Bahaghari's subproject.
{ ... }:

{
  flake = {
    nixosModules = {
      "bahaghari/tinted-theming" = ../../modules/bahaghari/modules/tinted-theming;
    };

    bahaghariLib = {
      default = ../../modules/bahaghari/lib;
      tinted-theming = ../../modules/bahaghari/lib/tinted-theming.nix;
    };
  };
}
