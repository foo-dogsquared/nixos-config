# This is the user that is often used for servers.
{ lib, pkgs, ... }:

{
  users.users.plover = {
    # Change this immediately pls.
    initialHashedPassword = "$6$gpgBrL3.RAGa9NBp$93Ac5ZW53KcgbA9q4awVKA.bVArP7Hw1NbyakT30Mav.7obIuN17WWijT.EaBSJU6ArvdXTehC3xZ9/9oZPDR0";
    extraGroups = [ "wheel" ];
    useDefaultShell = true;
    isNormalUser = true;
    description = "The go-to user for server systems.";
  };

  environment.systemPackages = with pkgs; [
    wireshark-cli
    bind.dnsutils
    nettools
    bat
    fd
    jq
  ];
}
