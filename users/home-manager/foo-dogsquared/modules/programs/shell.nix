# My user shell of choice because I'm not a hipster.
{ config, lib, pkgs, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.programs.shell;
in
{
  options.users.foo-dogsquared.programs.shell.enable =
    lib.mkEnableOption "configuration of foo-dogsquared's shell of choice and its toolbelt";

  config = lib.mkIf cfg.enable {
    # Add the dev home-manager profiles to be more of a hipster.
    profiles.dev = {
      enable = true;
      extras.enable = true;
      coreutils-replacement.enable = true;
      shell.enable = true;
      servers.enable = true;
    };

    programs.bash = {
      enable = true;
      historyControl = [ "erasedups" "ignoredups" "ignorespace" ];
      historyIgnore = [
        "cd"
        "exit"
        "lf"
        "ls"
        "nvim"
      ];
    };

    # Set up with these variables.
    systemd.user.sessionVariables = {
      PAGER = "moar";
      MANPAGER = "nvim +Man!";
      EDITOR = "nvim";
    };

    # Add it to the laundry list.
    services.bleachbit.cleaners = [ "bash.history" ];
  };
}
