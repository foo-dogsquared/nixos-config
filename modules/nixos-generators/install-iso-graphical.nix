# A custom nixos-generator module to set as a graphical installation with a
# graphical installer profile. Useful for hosts that can be used both as a
# persistent live installer or as a graphical ISO. Based from the original
# install-iso format.
{ lib, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares.nix"
  ];

  # override installation-cd-base and enable wpa and sshd start at boot
  systemd.services.wpa_supplicant.wantedBy =
    lib.mkForce [ "multi-user.target" ];
  systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];

  formatAttr = "isoImage";
  fileExtension = ".iso";
}
