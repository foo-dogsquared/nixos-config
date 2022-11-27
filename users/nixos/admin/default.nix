# This is the main account for servers. It is also used for managing the
# installations with deploy-rs.
{ config, lib, pkgs, ... }:

{
  users.users.admin = {
    description = "The administrator account for the servers.";
    hashedPassword = "$6$QEHdYhTige1mhCyT$yIfecQpV0PZJNxdxVLiRAk.0UxYXYxASlzzyBoYqEkbRx2fsaF81JKaw.Alb.ENKY.5UKkGdcV8H4bPAdJIwR1";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    useDefaultShell = true;
    openssh.authorizedKeys.keyFiles = [
      ../../home-manager/foo-dogsquared/user-key.pub
      ../../../hosts/ni/host-key.pub
    ];
  };

  nix.settings.trusted-users = [ "admin" ];
}
