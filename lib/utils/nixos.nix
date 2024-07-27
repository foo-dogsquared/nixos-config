{ lib }:

{
  # This is only used for home-manager users without a NixOS user counterpart.
  mapHomeManagerUser = user: settings:
    let
      homeDirectory = "/home/${user}";
    in
    ({ lib, ... }: {
      home-manager.users."${user}" = { ... }: {
        imports = [
          {
            home.username = user;
            home.homeDirectory = homeDirectory;
          }

          ../../configs/home-manager/${user}
        ];
      };

      users.users."${user}" = lib.mkMerge [
        {
          extraGroups = lib.mkDefault [ "wheel" ];
          createHome = lib.mkDefault true;
          home = lib.mkDefault homeDirectory;
          isNormalUser = lib.mkForce true;
        }
        settings
      ];
    });

  /* Returns the file path of the given config of the given environment.

     Type: getConfig :: String -> String -> Path

     Example:
       getConfig "home-manager" "foo-dogsquared"
       => ../configs/home-manager/foo-dogsquared
  */
  getConfig = type: config: ../../configs/${type}/${config};

  /* Returns the file path of the given user subpart of the given
     environment. Only certain environments such as NixOS have this type of
     setup.

     Type: getConfig :: String -> String -> Path

     Example:
       getUser "nixos" "foo-dogsquared"
       => ../configs/nixos/_users/foo-dogsquared
  */
  getUser = type: user: ../../configs/${type}/_users/${user};
}
