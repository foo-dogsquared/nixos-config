{
  config,
  lib,
  pkgs,
  ...
}:

{
  wrappers.nvim = {
    arg0 = lib.getExe' pkgs.neovim "nvim";
    xdg.desktopEntry = {
      enable = true;
      settings = {
        terminal = true;
        extraConfig."X-GNOME-Autostart-Phase" = "WindowManager";
        keywords = [ "Text editor" ];
        startupNotify = false;
        startupWMClass = "MyOwnClass";
      };
    };
  };

  xdg.desktopEntries.nvim-custom = {
    name = "nvim-custom";
    genericName = "Text editor";
    terminal = true;
    exec = "nvim";
  };

  build.extraPassthru.wrapperManagerTests = {
    actuallyBuilt =
      let
        wrapper = config.build.toplevel;
      in
      pkgs.runCommand "wrapper-manager-xdg-desktop-entry-actually-built" { } ''
        [ -e "${wrapper}/share/applications/nvim-custom.desktop" ] \
          && [ -e "${wrapper}/share/applications/nvim.desktop" ] \
          && [ -x "${wrapper}/bin/${config.wrappers.nvim.executableName}" ] && touch $out
      '';
  };

}
