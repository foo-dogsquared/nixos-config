{ lib, ... }:

{
  setups.wrapper-manager = {
    configs = {
      archive-setup = {
        systems = [ "x86_64-linux" ];
        nixpkgs.branch = "nixos-unstable";
      };
    };
  };

  flake.wrapperManagerModules.default = ../../modules/wrapper-manager;
}
