# All of the functions suitable only for NixOS.
{ pkgs, config, lib }:

rec {
  # This is only used for home-manager users without a NixOS user counterpart.
  mapHomeManagerUser = user: settings:
    let
      homeDirectory = "/home/${user}";
      defaultUserConfig = {
        extraGroups = pkgs.lib.mkDefault [ "wheel" ];
        createHome = pkgs.lib.mkDefault true;
        home = pkgs.lib.mkDefault homeDirectory;
        isNormalUser = pkgs.lib.mkForce true;
      };
    in
    ({ lib, ... }: {
      home-manager.users."${user}" = { ... }: {
        imports = [
          {
            home.username = user;
            home.homeDirectory = homeDirectory;
          }

          ../configs/home-manager/${user}
        ];
      };

      users.users."${user}" = lib.mkMerge [
        defaultUserConfig
        settings
      ];
    });

  # Checks if the NixOS configuration is part of the nixos-generator build.
  # Typically, we just check if there's a certain attribute that is imported
  # from it.
  hasNixosFormat =
    pkgs.lib.hasAttrByPath [ "formatAttr" ] config;

  # Checks if the NixOS config is being built for a particular format.
  isFormat = format:
    hasNixosFormat && config.formatAttr == format;
}
