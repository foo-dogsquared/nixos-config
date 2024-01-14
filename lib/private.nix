# This is just a library intended solely for this flake.
# It is expected to use the nixpkgs library with `lib/default.nix`.
{ lib }:

rec {
  # This is only used for home-manager users without a NixOS user counterpart.
  mapHomeManagerUser = user: settings:
    let
      homeDirectory = "/home/${user}";
      defaultUserConfig = {
        extraGroups = lib.mkDefault [ "wheel" ];
        createHome = lib.mkDefault true;
        home = lib.mkDefault homeDirectory;
        isNormalUser = lib.mkForce true;
      };
    in
    ({ lib, ... }: {
      home-manager.users."${user}" = { ... }: {
        imports = [
          {
            home.username = user;
            home.homeDirectory = homeDirectory;
          }

          (getConfig "home-manager" user)
        ];
      };

      users.users."${user}" = lib.mkMerge [
        defaultUserConfig
        settings
      ];
    });

  getConfig = type: config: ../configs/${type}/${config};

  getUser = type: user: ../configs/${type}/_users/${user};
}
