{ config, lib, pkgs, foodogsquaredLib, ... }@attrs:

let
  inherit (foodogsquaredLib.xdg) getXdgDesktop;

  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.programs.terminal-emulator;

  shellIntegrationFragment = ''
    source ${pkgs.bash-preexec}/share/bash/bash-preexec.sh
    source ${config.programs.wezterm.package}/etc/profile.d/wezterm.sh
  '';

  hasNixosModuleEnable = attrs.nixosConfig.programs.wezterm.enable or false;

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
in {
  options.users.foo-dogsquared.programs.terminal-emulator.enable =
    lib.mkEnableOption "foo-dogsquared's terminal emulator setup";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      # We're just making a version of Wezterm with the default arguments if
      # the user has them.
      home.packages = let
        inherit (pkgs) wezterm hiPrio;
      in [ wezterm (hiPrio weztermUserDefaultDesktop) ];

      xdg.autostart.entries =
        lib.singleton (getXdgDesktop weztermUserDefaultDesktop "org.wezfurlong.wezterm");

      # Based from https://mwop.net/blog/2024-09-17-wezterm-dropdown.html
      wrapper-manager.packages.wezterm-wrappers = { config, ... }: let
        dropdownName = "one.foodogsquared.WeztermDropDown";
      in {
        wrappers.${dropdownName} = {
          arg0 = lib.getExe' pkgs.wezterm "wezterm";
          prependArgs = let
            configs = [
              "window_decorations='NONE'"
              "window_background_opacity=0.875"
            ];
            mkConfigs = c: [
              "--config" c
            ];
          in
            lib.concatMap mkConfigs configs
            ++ [
              "start"
              "--cwd" "."
              "--class" dropdownName
              "--domain" "unix"
              "--attach"
              "--workspace dropdown"
            ];
        };

        xdg.desktopEntries."${dropdownName}" = {
          desktopName = "Wezterm (dropdown)";
          exec = config.wrappers.${dropdownName}.executableName;
          tryExec = "wezterm";
          icon = "org.wezfurlong.wezterm";
          categories = [ "System" "TerminalEmulator" "Utility" ];
          comment = "Open Wezterm as a dropdown terminal";
          startupWMClass = dropdownName;
        };

        xdg.desktopEntries."wezterm-start" = {
          desktopName = "WezTerm";
          tryExec = "wezterm";
          exec = "wezterm start --cwd .";
          comment = "Wez's Terminal Emulator";
          keywords = [ "shell" "prompt" "command" "commandline" "cmd" ];
          icon = "org.wezfurlong.wezterm";
          startupWMClass = "org.wezfurlong.wezterm";
          categories = [ "System" "TerminalEmulator" "Utility" ];
        };
      };
    }

    (lib.mkIf (!hasNixosModuleEnable) {
      programs.bash.initExtra = shellIntegrationFragment;
      programs.zsh.initExtra = shellIntegrationFragment;
    })
  ]);
}
