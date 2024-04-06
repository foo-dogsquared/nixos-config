{ lib, config, pkgs, foodogsquaredModulesPath, ... }:

# Since this will be exported as an installer ISO, you'll have to keep in mind
# about the added imports from nixos-generators. In this case, it simply adds
# the NixOS installation CD profile.
#
# This means, there will be a "nixos" user among other things.
{
  imports = [
    "${foodogsquaredModulesPath}/profiles/installer.nix"
  ];

  config = lib.mkMerge [
    {
      boot.kernelPackages = pkgs.linuxPackages_6_6;

      # Assume that this will be used for remote installations.
      services.openssh = {
        enable = true;
        allowSFTP = true;
      };

      system.stateVersion = "23.11";
    }

    (lib.mkIf (config.formatAttr == "isoImage") {
      isoImage = {
        isoBaseName = config.networking.hostName;

        squashfsCompression = "zstd -Xcompression-level 11";

        makeEfiBootable = true;
        makeUsbBootable = true;
      };
    })
  ];
}
