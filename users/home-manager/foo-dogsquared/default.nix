{ config, options, lib, pkgs, ... }:

let
  dotfilesAsStorePath = config.lib.file.mkOutOfStoreSymlink config.home.mutableFile."library/dotfiles".path;
  getDotfiles = path: "${dotfilesAsStorePath}/${path}";
in
{
  imports = [
    ./modules/email.nix
    ./modules/keys.nix
    ./modules/git.nix
    ./modules/music.nix
  ];

  home.packages = with pkgs; [
    vscodium-fhs # Visual Studio-lite and for those who suffer from Visual Studio withdrawal.
    hledger # Trying to be a good accountant.
    hledger-utils # For extra trying to be a better accountant.
  ];

  fonts.fontconfig.enable = true;

  programs.atuin = {
    settings = {
      auto_sync = true;
      sync_address = "http://atuin.plover.foodogsquared.one";
      sync_frequency = "10m";
    };
  };

  programs.bash.sessionVariables.PATH = "${config.home.mutableFile."library/dotfiles".path}/bin\${PATH:+:$PATH}";

  # Making my favorite terminal multiplexer right now.
  programs.zellij.settings = {
    default_layout = "editor";
    layout_dir = builtins.toString ./config/zellij/layouts;
  };

  # My preferred file indexing service.
  services.recoll = {
    enable = true;
    startAt = "daily";
    settings = {
      topdirs = "~/Downloads ~/Documents ~/library";
      "skippedNames+" = "node_modules";

      "~/library/projects" = {
        "skippedNames+" = ".editorconfig .gitignore result flake.lock go.sum";
      };

      "~/library/projects/software" = {
        "skippedNames+" = "target result";
      };
    };
  };

  # My custom modules.
  profiles = {
    dev = {
      enable = true;
      shell.enable = true;
      extras.enable = true;
    };
    editors.emacs.enable = true;
    desktop = {
      enable = true;
      graphics.enable = true;
      video.enable = true;
      documents.enable = true;
    };
    research.enable = true;
  };

  services.bleachbit = {
    enable = true;
    cleaners = [
      "bash.history"
      "winetricks.temporary_files"
      "wine.tmp"
      "discord.history"
      "google_earth.temporary_files"
      "google_toolbar.search_history"
      "thumbnails.cache"
      "zoom.logs"
      "vim.history"
    ];
    withChatCleanup = true;
    withBrowserCleanup = true;
    persistent = true;
  };

  systemd.user.sessionVariables = {
    MANPAGER = "nvim +Man!";
    EDITOR = "nvim";
  };

  # WHOA! Even browsers with extensions can be declarative!
  programs.brave = {
    enable = true;
    extensions = [
      { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # Vimium
      { id = "ekhagklcjbdpajgpjgmbionohlpdbjgc"; } # Zotero connector
      { id = "jfnifeihccihocjbfcfhicmmgpjicaec"; } # GSConnect
      { id = "aapbdbdomjkkjkaonfhkkikfgjllcleb"; } # Google Translate
      { id = "egpjdkipkomnmjhjmdamaniclmdlobbo"; } # Firenvim
      { id = "gknkbkaapnhpmkcgkmdekdffgcddoiel"; } # Open Access Button
      { id = "fpnmgdkabkmnadcjpehmlllkndpkmiak"; } # Wayback Machine
      { id = "gphhapmejobijbbhgpjhcjognlahblep"; } # GNOME Shell integration
      { id = "haebnnbpedcbhciplfhjjkbafijpncjl"; } # TinEye Reverse Image Search
      { id = "dhdgffkkebhmkfjojejmpbldmpobfkfo"; } # Tampermonkey
      { id = "kkmlkkjojmombglmlpbpapmhcaljjkde"; } # Zhongwen
      { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
      { id = "oldceeleldhonbafppcapldpdifcinji"; } # LanguageTool checker
    ];
  };

  home.stateVersion = "23.05";

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  # All of the personal configurations.
  xdg.configFile = {
    "doom".source = getDotfiles "emacs";
    "kitty".source = getDotfiles "kitty";
    "lf".source = getDotfiles "lf";
    "nvim".source = getDotfiles "nvim";
    "wezterm".source = getDotfiles "wezterm";
  };

  # Automating some files to be fetched on activation.
  home.mutableFile = {
    # Fetching my dotfiles,...
    "library/dotfiles" = {
      url = "https://github.com/foo-dogsquared/dotfiles.git";
      type = "git";
    };

    # ...Doom Emacs,...
    "${config.xdg.configHome}/emacs" = {
      url = "https://github.com/doomemacs/doomemacs.git";
      type = "git";
      extraArgs = [ "--depth" "1" ];
    };

    # ...and my custom theme to be a showoff.
    "${config.xdg.dataHome}/base16/bark-on-a-tree" = {
      url = "https://github.com/foo-dogsquared/base16-bark-on-a-tree-scheme.git";
      type = "git";
    };
  };

  systemd.user.services.fetch-mutable-files = {
    Service.ExecStartPost =
      let
        script = pkgs.writeShellScript "post-fetch-mutable-files" ''
          # Automate installation of Doom Emacs.
          ${config.xdg.configHome}/emacs/bin/doom install --no-config --no-fonts --install --force
          ${config.xdg.configHome}/emacs/bin/doom sync
        '';
      in
      builtins.toString script;
  };
}
