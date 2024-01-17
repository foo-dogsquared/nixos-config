# Unlike other custom modules such as from NixOS and home-manager, all
# flake-part modules are considered internal so there's no need for an internal
# flag. We can just import these directly. Nobody should be using this except
# this project (and also my other projects).
{ lib, ... }:

{
  imports = [
    ./images.nix
    ./deploy-rs-nodes.nix
    ./home-modules.nix
    ./setups
  ];
}
