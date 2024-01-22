# My editor configurations. Take note I try to avert as much settings to create
# the configuration files with Nix. I prefer to handle the text editor
# configurations by hand as they are very chaotic and it is a hassle going
# through Nix whenever I need to change it.
#
# As much as I want 100% reproducibility with Nix, 5% of the remaining stuff
# for me is not worth to maintain.
{ config, lib, pkgs, ... }:

let cfg = config.suites.editors;
in {
  options.suites.editors = {
    neovim.enable = lib.mkEnableOption "basic Neovim setup";
    vscode.enable = lib.mkEnableOption "basic Visual Studio Code setup";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.neovim.enable {
      programs.neovim = {
        enable = true;
        withPython3 = true;
        withRuby = true;
        withNodeJs = true;

        plugins = with pkgs.vimPlugins; [
          parinfer-rust
        ];
      };

      xdg.mimeApps.defaultApplications = {
        "application/json" = [ "nvim.desktop" ];
        "text/plain" = [ "nvim.desktop" ];
      };
    })

    # The Visual Studio Code setup. Probably the hardest one to fully configure
    # not because it has extensions available which will make things harder.
    # This might make me not consider an extension and settings sync extension
    # for this.
    (lib.mkIf cfg.vscode.enable {
      programs.vscode = {
        enable = true;
        extensions = with pkgs.vscode-extensions; [
          # All the niceties for developmenties.
          ms-vscode-remote.remote-containers
          ms-vscode-remote.remote-ssh
          ms-vsliveshare.vsliveshare
          tailscale.vscode-tailscale

          # The other niceties.
          vscode-icons-team.vscode-icons
        ];

        # Yay! Thank you!
        mutableExtensionsDir = true;

        userSettings = {
          # Editor configurations.
          "editor.fontFamily" = "monospace";
          "editor.fontSize" = 16;
          "editor.cursorStyle" = "block";
          "editor.minimap.renderCharacters" = false;
          "workbench.iconTheme" = "vscode-icons";
          "window.autoDetectColorScheme" = true;
          "accessibility.dimUnfocused.enable" = true;
          "accessibility.dimUnfocused.opacity" = 0.35;

          # Putting some conveniences.
          "files.autoSave" = "off";
          "update.showReleaseNotes" = false;
          "extensions.autoUpdate" = "onlyEnabledExtensions";
          "github.copilot.enable"."*" = false;

          # Extensions settings.
          "direnv.restart.automatic" = true;
          "gitlens.showWhatsNewAfterUpgrade" = false;
          "gitlens.showWelcomeOnInstall" = false;
          "gitlens.plusFeatures.enabled" = false;
        };
      };

      xdg.mimeApps.defaultApplications = {
        "application/json" = [ "code.desktop" ];
        "text/plain" = [ "code.desktop" ];
      };
    })
  ];
}
