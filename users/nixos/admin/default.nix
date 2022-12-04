# This is the main account for servers. It is also used for managing the
# installations with deploy-rs.
{ config, lib, pkgs, ... }:

let
  name = "admin";
in
{
  users.users.${name} = {
    description = "The administrator account for the servers.";
    hashedPassword = "$6$KXZD6NvjtSkle/id$ECs7zIwDBOlQiFACsyot1gyjKG9UWMlUdRknVujE9efpHMQGx7.YZWyJ0VkV0ja0BPzeF/EzTu6n4EEF5ZHPD0";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    useDefaultShell = true;
    openssh.authorizedKeys.keyFiles = [
      ../../home-manager/foo-dogsquared/files/ssh-key.pub
      ../../../hosts/ni/files/ssh-key.pub
    ];
  };

  # This is also a trusted user for the Nix daemon.
  nix.settings.trusted-users = [ name ];

  # Allow the user to easily enter into several services such as the database
  # services to allowing some debugging.
  services.postgresql.ensureUsers = [ { inherit name; } ];
  services.mysql.ensureUsers = [ { inherit name; } ];
}
