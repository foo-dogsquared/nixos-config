# All of the functions suitable only for NixOS.
{ pkgs, lib }:

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
}
