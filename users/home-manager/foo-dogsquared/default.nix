{ config, lib, pkgs, ... }:

{
  imports = [ ./modules ];

  # All of the home-manager-user-specific setup are here.
  users.foo-dogsquared = {
    music.enable = true;
    dotfiles.enable = false;

    programs = {
      browsers.brave.enable = true;
      browsers.firefox.enable = true;
      browsers.misc.enable = true;
      email.enable = true;
      email.thunderbird.enable = true;
      git.enable = true;
      keys.gpg.enable = true;
      keys.ssh.enable = true;
      research.enable = true;
      shell.enable = true;
      terminal-multiplexer.enable = true;
    };

    services.desktop.enable = true;
  };

  # The keyfile required to decrypt the secrets.
  sops.age.keyFile = "${config.xdg.configHome}/age/user";

  sops.secrets = lib.getSecrets ./secrets/secrets.yaml {
    davfs2-credentials = {
      path = "${config.home.homeDirectory}/.davfs2/davfs2.conf";
    };
  };

  # Set nixpkgs config both outside and inside of home-manager.
  nixpkgs.config = import ./config/nixpkgs/config.nix;
  xdg.configFile."nixpkgs/config.nix".source = ./config/nixpkgs/config.nix;

  home.packages = with pkgs; [
    hledger # Trying to be a good accountant.
  ];

  fonts.fontconfig.enable = true;

  programs.atuin = {
    settings = {
      auto_sync = true;
      sync_address = "http://atuin.plover.foodogsquared.one";
      sync_frequency = "10m";
    };
  };

  # My custom modules.
  profiles = {
    editors = {
      emacs.enable = true;
      vscode.enable = true;
    };
    desktop = {
      enable = true;
      graphics.enable = true;
      video.enable = true;
      documents.enable = true;
    };
  };

  home.stateVersion = "23.11";

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  xdg.configFile = {
    distrobox.source = ./config/distrobox;
    kanidm.source = ./config/kanidm;
  };

  # Automating some files to be fetched on activation.
  home.mutableFile = {
    # ...my gopass secrets,...
    ".local/share/gopass/stores/personal" = {
      url = "gitea@code.foodogsquared.one:foodogsquared/gopass-secrets-personal.git";
      type = "gopass";
    };

    # ...and my custom theme to be a showoff.
    "${config.xdg.dataHome}/base16/bark-on-a-tree" = {
      url = "https://github.com/foo-dogsquared/base16-bark-on-a-tree-scheme.git";
      type = "git";
    };
  };
}
