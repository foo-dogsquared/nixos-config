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
    suites.dev.shell.enable = lib.mkDefault true;

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

    # Additional formatting thingies for your fuzzy finder.
    programs.fzf.defaultOptions = [
      "--height=40%"
      "--bind=ctrl-z:ignore"
      "--reverse"
    ];

    # Compile all of the completions.
    programs.carapace.enable = true;

    programs.atuin = {
      enable = true;
      settings = {
        auto_sync = true;
        sync_address = "http://atuin.plover.foodogsquared.one";
        sync_frequency = "10m";
        update_check = false;
        workspaces = true;
      };
    };

    # Set up with these variables.
    systemd.user.sessionVariables.PAGER = "moar";

    # Add it to the laundry list.
    services.bleachbit.cleaners = [ "bash.history" ];
  };
}
