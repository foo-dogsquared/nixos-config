{ inputs, lib, ... }:

{
  setups.wrapper-manager = {
    configs = {
      archive-setup = {
        systems = [ "x86_64-linux" ];
        nixpkgs.branch = "nixos-unstable";
      };

      dotfiles-wrapped = {
        systems = [ "x86_64-linux" ];
        nixpkgs.branch = "nixos-unstable";
      };

      software-dev = {
        systems = [ "x86_64-linux" ];
        nixpkgs.branch = "nixos-unstable";
      };
    };
  };

  flake.wrapperManagerModules.default = inputs.fds-core.wrapperManagerModules.default;
}
