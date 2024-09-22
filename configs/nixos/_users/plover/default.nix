# This is the user that is often used for servers.
{ foodogsquaredUtils, ... }:

let
  user = "plover";
  homeManagerUser = foodogsquaredUtils.getConfig "home-manager" user;
in
{
  users.users.${user} = {
    home = "/home/${user}";
    hashedPassword = "$6$gpgBrL3.RAGa9NBp$93Ac5ZW53KcgbA9q4awVKA.bVArP7Hw1NbyakT30Mav.7obIuN17WWijT.EaBSJU6ArvdXTehC3xZ9/9oZPDR0";
    extraGroups = [ "wheel" "wireshark" ];
    useDefaultShell = true;
    isNormalUser = true;
    description = "The go-to user for server systems.";

    openssh.authorizedKeys.keyFiles = [
      ../../../home-manager/foo-dogsquared/files/ssh-key.pub
      ../../../home-manager/foo-dogsquared/files/ssh-key-2.pub
    ];
  };

  programs.wireshark.enable = true;

  home-manager.users.${user} = {
    imports = [ homeManagerUser ];
  };
}
