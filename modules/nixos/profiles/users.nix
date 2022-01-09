# This enables home-manager specific configs and an easier modularization for
# user-specific configurations. This is specifically for creating a convenient
# way to create users from `users/home-manager`.
#
# If you're looking to create users from `users/nixos`, you can just import
# them directly.
{ inputs, config, options, lib, ... }:

let
  cfg = config.profiles.users;
  users = lib.attrNames cfg.users;
  homeManagerUserModules = lib.getUsers "home-manager" users;
  homeManagerModules = lib.filesToAttr ../../home-manager;

  homeManagerUsers = lib.attrNames homeManagerUserModules;
  nonexistentUsers = lib.filter (name: !lib.elem name homeManagerUsers) users;

  userOption = { name, config, ... }: {
    options = {
      settings = lib.mkOption {
        type = lib.types.attrs;
        description =
          "Configuration to be merged in <literal>users.users.<name></literal> from NixOS configuration.";
        default = { };
        example = {
          uid = 1234;
          description = "John Doe";
          extraGroups = [ "wheel" "adbusers" "audio" ];
        };
      };
    };
  };

  mapUsers = f: lib.mapAttrs f cfg.users;
in {
  options.profiles.users = {
    users = lib.mkOption {
      default = { };
      description = ''
        A set of users from the `./users/home-manager` directory to be included in the NixOS config.
                This will also create the appropriate user settings in <literal>users.users</literal> in the NixOS configuration.'';
      example = {
        foo-dogsquared.settings = {
          extraGroups = [ "wheel" "audio" "libvirtd" ];
        };
        alice = { };
        bob = { };
      };
      type = with lib.types; attrsOf (submodule userOption);
    };
  };

  imports = [ inputs.home-manager.nixosModules.home-manager ];

  config = {
    assertions = [{
      assertion = (builtins.length nonexistentUsers) < 1;
      message = "${
          lib.concatMapStringsSep ", " (u: "'${u}'") nonexistentUsers
        } is not found in the `./users/home-manager` directory.";
    }];

    # The global configuration for the home-manager module.
    home-manager.useUserPackages = true;
    home-manager.useGlobalPkgs = true;
    home-manager.sharedModules = lib.modulesToList homeManagerModules;

    # Mapping each users to the respective user configuration.
    # Setting users for home-manager.
    home-manager.users = mapUsers (user: _:
      let homeManagerUserModulePath = lib.getAttr user homeManagerUserModules;
      in import homeManagerUserModulePath);

    # NixOS users.
    users.users = mapUsers (user: opts:
      let
        defaultUserConfig = {
          extraGroups = [ "wheel" ];
          createHome = true;
          home = "/home/${user}";
        };
        # TODO: Effectively override the option.
        # We assume all users set with this module are normal users.
        absoluteOverrides = { isNormalUser = true; };
      in defaultUserConfig // opts.settings // absoluteOverrides);
  };
}
