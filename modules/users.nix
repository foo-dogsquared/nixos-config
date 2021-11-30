# This enables home-manager specific configs and an easier modularization for user-specific configurations.
{ inputs, config, options, lib, ... }:

let
  cfg = config.modules.users;
  invalidUsernames = [ "config" "modules" ];
  userModules = lib.filterAttrs (n: _: !lib.elem n invalidUsernames)
    (lib.filesToAttr ../users);
  homeManagerModules =
    lib.filterAttrs (n: _: n == "modules") (lib.filesToAttr ../users);

  users = lib.attrNames userModules;
  nonexistentUsers = lib.filter (name: !lib.elem name users) cfg.users;

  mkUser = user: modulePath:
    let
      userModule = import modulePath;
      defaultConfig = {
        home.username = user;
        home.homeDirectory = "/home/${user}";

        xdg.enable = true;
      };
    in {
      users.users.${user} = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
      };
      home-manager.users.${user} = import modulePath;
    };
in {
  options.modules.users = {
    users = lib.mkOption {
      default = [ ];
      type = with lib.types; listOf str;
      description =
        "A list of users from the `./users` directory to be included in the NixOS config.";
    };
  };

  # FIXME: Recursion error when using `lib.getUsers cfg.users`.
  # Time to study how Nix modules really work.
  # The assertion is basically enough for this case.
  imports = [
    # home-manager to enable user-specific config.
    inputs.home-manager.nixosModules.home-manager

    # The global configuration for the home-manager module.
    {
      home-manager.useUserPackages = true;
      home-manager.useGlobalPkgs = true;
      home-manager.sharedModules = lib.modulesToList homeManagerModules;
    }
  ] ++ (lib.mapAttrsToList mkUser userModules);

  config = {
    assertions = [{
      assertion = (builtins.length nonexistentUsers) < 1;
      message = "${
          lib.concatMapStringsSep ", " (u: "'${u}'") nonexistentUsers
        } is not found in the `./users` directory.";
    }];
  };
}
