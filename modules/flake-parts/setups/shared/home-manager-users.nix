# Take note that the individual setup module would have to take care of
# integrating the users into their respective environment.
{ config, options, lib, ... }:

let
  homeManagerUserType = { name, config, lib, ... }: {
    options = {
      additionalModules = lib.mkOption {
        type = with lib.types; listOf deferredModule;
        description = ''
          A list of additional home-manager modules to be added with the
          user.
        '';
      };
    };
  };
in {
  # This option is for the wider-scoped environment to be easily compatible
  # with the home-manager flake-parts module where it also shares the Nix
  # configuration submodule. Without this option, it would not work (or we
  # could just rename the options from the home-manager module).
  imports = [
    (lib.mkAliasOptionModule [ "homeManagerBranch" ] [
      "home-manager"
      "branch"
    ])
  ];

  options.home-manager = {
    branch = lib.mkOption {
      type = with lib.types; nullOr nonEmptyStr;
      description = ''
        The name of the home-manager branch to be used. Take note this should
        be set with care as home-manager typically recommends to be used with
        the apprioriate nixpkgs branch.
      '';
      default = null;
      example = "home-manager-stable";
    };

    users = lib.mkOption {
      type = with lib.types; attrsOf (submodule homeManagerUserType);
      description = ''
        A set of home-manager users from {option}`setups.home-manager.configs` to
        be included with the wider-scoped environment.
      '';
      default = { };
      example = {
        foo-dogsquared = {
          userConfig = {
            uid = 1000;
            extraGroups = [
              "adm"
              "adbusers"
              "wheel"
              "audio"
              "docker"
              "podman"
              "networkmanager"
              "systemd-journal"
              "wireshark"
            ];
          };
        };

        plover.userConfig = { extraGroups = [ "adm" "wheel" ]; };
      };
    };
  };
}
