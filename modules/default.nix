{ config, options, lib, ... }:

with lib;

let
  mkOptionStr = value:
    mkOption {
      type = types.str;
      default = value;
    };
in {
  imports = [
    <home-manager/nixos>

    ./desktop
    ./dev
    ./hardware
    ./editors
    ./shell
    ./services
    ./themes
  ];

  options = {
    my = {
      # Personal details
      username = mkOptionStr "foo-dogsquared";
      email = mkOptionStr "foo.dogsquared@gmail.com";

      # Convenience aliases
      home =
        mkOption { type = options.home-manager.users.type.functor.wrapped; };
      user = mkOption { type = options.users.users.type; };
      packages = mkOption { type = with types; listOf package; };

      # Environment
      env = mkOption {
        type = with types;
          attrsOf (either (either str path) (listOf (either str path)));
        apply = mapAttrs (n: v:
          if isList v then
            concatMapStringsSep ":" (x: toString x) v
          else
            (toString v));
      };

      alias = mkOption {
        type = with types; nullOr (attrsOf (nullOr (either str path)));
      };
    };
  };

  config = {
    # Convenience aliases
    home-manager.users.${config.my.username} =
      mkAliasDefinitions options.my.home;
    home-manager.useGlobalPkgs = true;
    users.users.${config.my.username} = mkAliasDefinitions options.my.user;
    my.user.packages = config.my.packages;

    # PATH should always start with its old value
    my.env.PATH = [ <config/bin> "$PATH" ];

    # Put the configured custom environment variables (config.my.env) into initialization phase.
    environment.extraInit = let
      exportLines =
        mapAttrsToList (key: value: ''export ${key}="${value}"'') config.my.env;
    in ''
      export XAUTHORITY=/tmp/XAUTHORITY
      [ -e ~/.Xauthority ] && mv -f ~/.Xauthority "$XAUTHORITY"

       ${concatStringsSep "\n" exportLines}
    '';

    my.home = {
      programs = {
        bash.shellAliases = config.my.alias;
        zsh.shellAliases = config.my.alias;
        fish.shellAliases = config.my.alias;
      };
    };
  };
}
