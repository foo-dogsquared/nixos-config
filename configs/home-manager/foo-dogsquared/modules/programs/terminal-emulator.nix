{ config, lib, pkgs, ... }@attrs:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.programs.terminal-emulator;

  shellIntegrationFragment = ''
    source ${pkgs.bash-preexec}/share/bash/bash-preexec.sh
    source ${config.programs.wezterm.package}/etc/profile.d/wezterm.sh
  '';

  hasNixosModuleEnable = attrs.nixosConfig.programs.wezterm.enable or false;
in
{
  options.users.foo-dogsquared.programs.terminal-emulator.enable =
    lib.mkEnableOption "foo-dogsquared's terminal emulator setup";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      # We're just making a version of Wezterm with the default arguments if
      # the user has them.
      home.packages =
        let
          inherit (pkgs) wezterm hiPrio;
          weztermUserDefaultDesktop = pkgs.makeDesktopItem {
            name = "org.wezfurlong.wezterm";
            desktopName = "WezTerm (user)";
            comment = "Wez's Terminal Emulator";
            keywords = [ "shell" "prompt" "command" "commandline" "cmd" ];
            icon = "org.wezfurlong.wezterm";
            startupWMClass = "org.wezfurlong.wezterm";
            tryExec = "wezterm";
            exec = "wezterm";
            type = "Application";
            categories = [ "System" "TerminalEmulator" "Utility" ];
          };
          weztermTypicalDesktop = pkgs.makeDesktopItem {
            name = "wezterm-start";
            desktopName = "WezTerm";
            comment = "Wez's Terminal Emulator";
            keywords = [ "shell" "prompt" "command" "commandline" "cmd" ];
            icon = "org.wezfurlong.wezterm";
            startupWMClass = "org.wezfurlong.wezterm";
            tryExec = "wezterm";
            exec = "wezterm start --cwd .";
            type = "Application";
            categories = [ "System" "TerminalEmulator" "Utility" ];
          };
        in
          [
            wezterm
            (hiPrio weztermUserDefaultDesktop)
            weztermTypicalDesktop
          ];
    }

    (lib.mkIf (!hasNixosModuleEnable) {
      programs.bash.initExtra = shellIntegrationFragment;
      programs.zsh.initExtra = shellIntegrationFragment;
    })
  ]);
}
