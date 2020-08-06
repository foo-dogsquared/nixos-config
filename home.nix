{ config, pkgs, lib, ... }:

{
  imports = [
    ./modules
  ];

  # Setting my personal public information.
  # accounts.email.accounts."Gabriel Arazas" = {
  #   address = "christiangabrielarazas@gmail.com";
  #   aliases = [ "foo.dogsquared@gmail.com" ];
  # };

  nixpkgs.config = {
    allowUnfree = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Module configurations.
  modules = {
    desktop = {
      files.enable = true;
    };

    dev = {
      base.enable = true;
      cc.enable = true;
      documentation.enable = true;
      rust.enable = true;
    };

    editors = {
      default = "nvim";
      emacs.enable = true;
      neovim.enable = true;
    };

    shell = {
      base.enable = true;
      lf.enable = true;
      git.enable = true;
    };
  };

  programs.git = lib.mkIf config.modules.shell.git.enable {
    userName = "foo-dogsquared";
    userEmail = "christiangabrielarazas@gmail.com";
  };

  # Additional programs that doesn't need much configuration (or at least personally configured).
  # It is pointless to create modules for it, anyways.
  # home.packages = with pkgs; [
  #   cookiecutter    # A generic project scaffolding tool.
  # ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "foo-dogsquared";
  home.homeDirectory = "/home/foo-dogsquared";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.09";
}
