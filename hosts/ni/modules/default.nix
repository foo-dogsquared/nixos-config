# Only optional modules should be imported here.
{
  imports = [
    ./hardware/qol.nix
    ./networking/setup.nix
    ./networking/wireguard.nix
  ];
}
