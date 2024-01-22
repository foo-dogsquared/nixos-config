# A extended hardened configuration from nixpkgs for desktop and server
# systems.
{ pkgs, lib, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/profiles/hardened.nix"
  ];

  # Don't replace it mid-way! DON'T TURN LEFT!!!!
  security.protectKernelImage = true;

  # Hardened config equals hardened kernel.
  boot.kernelPackages = lib.mkOverride 500 pkgs.linuxKernel.packages.linux_6_6_hardened;

  # Disable system console entirely. We don't need it so get rid of it.
  boot.kernel.sysctl."kernel.sysrq" = 0;
}
