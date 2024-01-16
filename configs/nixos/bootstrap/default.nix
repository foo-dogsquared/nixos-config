{ lib, config, pkgs, ... }:

# Since this will be exported as an installer ISO, you'll have to keep in mind
# about the added imports from nixos-generators. In this case, it simply adds
# the NixOS installation CD profile.
#
# This means, there will be a "nixos" user among other things.
{
  isoImage = {
    isoBaseName = config.networking.hostName;

    # Store the source code in a easy-to-locate path.
    contents = [{
      source = ../..;
      target = "/etc/nixos/";
    }];

    squashfsCompression = "zstd -Xcompression-level 8";
  };

  boot.kernelPackages = pkgs.linuxPackages_6_6;

  # Assume that this will be used for remote installations.
  services.openssh = {
    enable = true;
    allowSFTP = true;
  };

  system.stateVersion = "23.11";
}
