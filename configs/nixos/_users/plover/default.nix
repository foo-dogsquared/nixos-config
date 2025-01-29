# This is the user that is often used for servers.
{ foodogsquaredUtils, ... }:

let
  user = "plover";
  homeManagerUser = foodogsquaredUtils.getConfig "home-manager" user;
in {
  users.users.${user} = {
    home = "/home/${user}";
    hashedPassword =
      "$y$j9T$43ExH5GLbEGwgnNGhmcTD/$qXoZE5Cm9O2Z3zMM/VyCZ18qN2Hc9.KvCnVz6tmjVVD";
    extraGroups = [ "wheel" "kanidm" ];
    useDefaultShell = true;
    isNormalUser = true;
    description = "The go-to user for server systems.";

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGo3tfNQjWZ5pxlqREfBgQJxdNzGHKJIy5hDS9Z+Hpth plover.foodogsquared.one"
    ];

    openssh.authorizedKeys.keyFiles = [
      ../../../home-manager/foo-dogsquared/files/ssh-key.pub
      ../../../home-manager/foo-dogsquared/files/ssh-key-2.pub
    ];
  };

  home-manager.users.${user} = { imports = [ homeManagerUser ]; };
}
