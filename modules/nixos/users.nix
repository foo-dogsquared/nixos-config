# This enables home-manager specific configs and an easier modularization for user-specific configurations.
# It will also map home-manager users to NixOS users, making it easy to
{ inputs, config, options, lib, ... }:

let
  userOption = {
    options = {
      config = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        example = {
          uid = 1234;
          description = "John Doe";
          extraGroups = [ "wheel" "adbusers" "audio" ];
        };
        description = ''Configuration to be merged in <literal>users.users.<name></literal>.'';
      };
    };
  };

  cfg = config.modules.users;
  homeManagerUsers = lib.getUsers "home-manager" (lib.attrNames cfg.users);
  homeManagerModules = lib.filesToAttr ../home-manager;

  mkUser = user: modulePath:
    let
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
      home-manager.users.${user} = defaultConfig // import modulePath;
    };

  nixosUsers = lib.mapAttrsToList mkUser homeManagerUsers;

  hmUsersList = lib.attrNames homeManagerUsers;
  nonexistentUsers = lib.filter (name: !lib.elem name hmUsersList) (lib.attrNames cfg.users);
in {
  options.modules.users = {
    users = lib.mkOption {
      default = { };
      type = with lib.types; attrsOf (submodule userOption);
      description = ''
        A set of users from the `./users` directory to be included in the NixOS config.

        If you don't have the corresponding home-manager user, just configure it directly with <literal>users.users</literal>.
      '';
      example = {
        foo-dogsquared.config = {
          extraGroups = [ "wheel" "audio" ];
        };
        alice.config = {};
      };
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
  ] ++ nixosUsers;

  config = {
    assertions = [{
      assertion = (builtins.length nonexistentUsers) < 1;
      message = "${
          lib.concatMapStringsSep ", " (u: "'${u}'") nonexistentUsers
        } is not found in the `./users` directory.";
    }];
  };
}
