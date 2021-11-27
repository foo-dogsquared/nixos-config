{ inputs, config, options, lib, ... }:

let
  cfg = config.modules.users;
  userModules = lib.filesToAttr ../users;

  users = lib.attrNames userModules;
  nonexistentUsers = lib.filter (name: !lib.elem name users) cfg.users;
  validUsers = lib.filterAttrs (n: v: lib.elem n users) userModules;
in
{
  options.modules.users = {
    users = lib.mkOption {
      default = [];
      type = with lib.types; listOf str;
      description = "A list of users from the `./users` directory to be included in the NixOS config.";
    };
  };

  imports = [ inputs.home-manager.nixosModules.home-manager ] ++ (lib.attrValues validUsers);

  config = {
    assertions = [{
      assertion = (builtins.length nonexistentUsers) < 1;
      message = "${lib.concatMapStringsSep ", " (u: "'${u}'") nonexistentUsers} is not found in the `./users` directory.";
    }];
  };
}
