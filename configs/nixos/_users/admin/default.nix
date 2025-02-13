# Mainly used for managing the installations with deploy-rs.
{ config, lib, pkgs, ... }:

let name = "admin";
in {
  users.users.${name} = {
    description = "The administrator account for the servers.";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    useDefaultShell = true;
    openssh.authorizedKeys.keyFiles = [
      ../../../home-manager/foo-dogsquared/files/ssh-key.pub
      ../../../home-manager/foo-dogsquared/files/ssh-key-2.pub
    ];
  };

  # We're going passwordless, baybee!
  security.sudo.extraRules = [{
    users = [ name ];
    commands = [{
      command = "ALL";
      options = [ "NOPASSWD" ];
    }];
  }];

  security.doas.extraRules = [{
    users = [ name ];
    noPass = true;
  }];

  # This is also a trusted user for the Nix daemon.
  nix.settings.trusted-users = [ name ];
}
