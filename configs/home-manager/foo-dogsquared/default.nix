{ config, lib, pkgs, foodogsquaredLib, ... }:

{
  imports = [ ./modules ];

  # All of the home-manager-user-specific setup are here.
  users.foo-dogsquared = {
    dotfiles.enable = true;

    programs = {
      dconf.enable = true;
      browsers.brave.enable = true;
      browsers.firefox.enable = true;
      browsers.misc.enable = true;
      doom-emacs.enable = true;
      nixvim.enable = true;
      email.enable = true;
      email.thunderbird.enable = true;
      research.enable = true;
      vs-code.enable = true;
    };

    setups = {
      desktop.enable = true;
      development.enable = true;
      fonts.enable = true;
      music.enable = true;
      music.mpd.enable = true;
    };
  };

  # Set the profile picture. Most of the desktop environments should support
  # this.
  home.file.".face".source = ./files/logo.png;

  # The keyfile required to decrypt the secrets.
  sops.age.keyFile = "${config.xdg.configHome}/age/user";

  sops.secrets = foodogsquaredLib.sops-nix.getSecrets ./secrets/secrets.yaml {
    davfs2-credentials = {
      path = "${config.home.homeDirectory}/.davfs2/davfs2.conf";
    };
  };

  # Add our own projects directory since most programs can't decide where it is
  # properly.
  xdg.userDirs.extraConfig.XDG_PROJECTS_DIR = "${config.home.homeDirectory}/Projects";

  # Set nixpkgs config both outside and inside of home-manager.
  nixpkgs.config = import ./config/nixpkgs/config.nix;
  xdg.configFile."nixpkgs/config.nix".source = ./config/nixpkgs/config.nix;

  home.packages = with pkgs; [
    gopass # An improved version of the password manager for hipsters.
    hledger # Trying to be a good accountant.
  ];

  home.stateVersion = "23.11";

  xdg.configFile = {
    distrobox.source = ./config/distrobox;
    kanidm.source = ./config/kanidm/config;
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

  # My own colorscheme just set somewhere. For now, this is manually set, we'll
  # have to import this with `lib.importYAML` or something similar.
  tinted-theming.schemes.bark-on-a-tree = {
    name = "Bark on a tree";
    author = "Gabriel Arazas";
    description = "Rusty theme resembling forestry inspired from Nord theme.";
    variant = "dark";
    palette = {
      base00 = "2b221f";
      base01 = "412c26";
      base02 = "5c362c";
      base03 = "a45b43";
      base04 = "e1bcb2";
      base05 = "f5ecea";
      base06 = "fefefe";
      base07 = "eb8a65";
      base08 = "d03e68";
      base09 = "df937a";
      base0A = "afa644";
      base0B = "85b26e";
      base0C = "eb914a";
      base0D = "c67f62";
      base0E = "8b7ab9";
      base0F = "7f3F83";
    };
  };

  tinted-theming.schemes.albino-bark-on-a-tree = {
    name = "Albino bark on a tree";
    author = "Gabriel Arazas";
    variant = "light";
    description = "Bright rusty theme resembling forestry inspired from Nord theme.";
    palette = {
      base00 = "f0f0f0";
      base01 = "e1e3e2";
      base02 = "dacec7";
      base03 = "9d5c4c";
      base04 = "54352c";
      base05 = "392c26";
      base06 = "2b220f";
      base07 = "cb6d48";
      base08 = "b52b52";
      base09 = "d56f17";
      base0A = "b0a52e";
      base0B = "5c963e";
      base0C = "e46403";
      base0D = "954c2f";
      base0E = "6751a5";
      base0F = "55195a";
    };
  };
}
