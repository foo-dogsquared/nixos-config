{ inputs, config, options, lib, ... }:

let
  cfg = config.modules.users;
  users = lib.attrNames (lib.filesToAttr ../users);
  nonexistentUsers = lib.filter (name: !lib.elem name users) cfg.users;
in
{
  options.modules.users = {
    users = lib.mkOption {
      default = [];
      type = with lib.types; listOf str;
      description = "A list of users from the `./users` directory to be included in the NixOS config.";
    };
  };

  imports = [ inputs.home-manager.nixosModules.home-manager ];
  config = lib.mkMerge [
    ({
      assertions = [{
        assertion = (builtins.length nonexistentUsers) > 1;
        message = "${lib.concatStringsSep "," users} ${lib.concatStringsSep "," nonexistentUsers} is not found in the directory.";
      }];
    })
  ];
}
