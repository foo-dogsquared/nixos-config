{ config, options, lib, pkgs, ... }:

let
  name = "a-happy-gnome";
  cfg = config.themes.themes.a-happy-gnome;
  terminalCommand = "${cfg.terminal}/bin/${cfg.terminal.meta.mainProgram or cfg.terminal.pname}";

  enabledExtensions = pkgs.writeTextFile {
    name = "a-happy-gnome-extensions";
    text = ''
      [org/gnome/shell]
      enabled-extensions=[${ lib.concatStringsSep ", " (lib.concatMap (e: [ ("'" + e.extensionUuid + "'") ]) cfg.shellExtensions) }]
    '';
  };

  miscConfig = pkgs.writeTextFile {
    name = "a-happy-gnome-misc-config";
    text = ''
      # Bringing my old habits back when I use standalone window managers.
      [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0]
      binding='<Super>Return'
      command='${terminalCommand}'
      name='Terminal'

      # The equivalent to the newspaper in the morning.
      [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1]
      binding='<Shift><Super>r'
      command='${terminalCommand} -e nix run nixpkgs#newsboat'
      name='News aggregator'
    '';
  };

  # We're combining all of the custom dconf database into a package to be installed.
  dconfConfig = pkgs.runCommand "install-a-happy-gnome-dconf-keyfiles" {} ''
    install -Dm644 ${./config/dconf}/*.conf -t $out/etc/dconf/db/${name}-conf.d
    install -Dm644 ${enabledExtensions} $out/etc/dconf/db/${name}-conf.d/enabled-extensions.conf
    install -Dm644 ${miscConfig} $out/etc/dconf/db/${name}-conf.d/misc.conf
  '';
in
{
  options.themes.themes.a-happy-gnome = {
    enable = lib.mkEnableOption "'A happy GNOME', foo-dogsquared's configuration of GNOME desktop environment";

    shellExtensions = lib.mkOption {
      type = with lib.types; listOf package;
      description = ''
        A list of GNOME Shell extensions to be included. Take note the package
        contain <literal>passthru.extensionUuid</literal> to be used for
        enabling the extensions.
      '';
      default = with pkgs.gnomeExtensions; [
        arcmenu
        appindicator
        alphabetical-app-grid
        burn-my-windows
        caffeine
        desktop-cube
        gsconnect
        x11-gestures
        kimpanel
        runcat
        just-perfection
        mpris-indicator-button
      ] ++ [
        pkgs.gnome-shell-extension-fly-pie
        pkgs.gnome-shell-extension-pop-shell
      ];
      example = lib.literalExpression ''
        with pkgs.gnomeExtensions; [
          appindicator
          gsconnect
          runcat
          just-perfection
        ];
      '';
      internal = true;
    };

    extraApps = lib.mkOption {
      type = with lib.types; listOf package;
      description = "A list of applications to be included in the theme.";
      default = with pkgs; [
        amberol # An unambitious music player.
        authenticator # 2-factor codes for 2-factor storages.
        blanket # Zen...
        gnome.dconf-editor # A saner version of Windows registry.
        gnome-dialect # Your gateway to polyglotting.
        gnome-solanum # Cute little matodor timers.
        shortwave # Yer' humble internet radio.

        # Nautilus extensions.
        nautilus-annotations
        nautilus-open-any-terminal
      ];
      example = lib.literalExpression ''
        with pkgs; [ gnome.polari ];
      '';
      internal = true;
    };

    terminal = lib.mkOption {
      type = lib.types.package;
      description = ''
        The preferred terminal application. This will be used for several
        keybindings that involves the terminal.
      '';
      default = pkgs.wezterm;
      defaultText = "pkgs.wezterm";
      example = lib.literalExpression "pkgs.kitty";
      internal = true;
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable GNOME and GDM.
    services.xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

    i18n.inputMethod = {
      enabled = "ibus";
      ibus.engines = with pkgs.ibus-engines; [
        mozc
        rime
        hangul
        table
        table-others
        typing-booster
      ];
    };

    # Since we're using KDE Connect, we'll have to use gsconnect.
    programs.kdeconnect = {
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };

    # Don't need most of the GNOME's offering so...
    environment.gnome.excludePackages = with pkgs.gnome; [
      gedit
      eog
      geary
      totem
      epiphany
      gnome-terminal
      yelp
    ];

    # I'm pretty sure this is already done but just to make sure.
    services.gnome.chrome-gnome-shell.enable = true;

    # Bring all of the dconf keyfiles in there.
    programs.dconf = {
      enable = true;
      packages = [ dconfConfig ];

      # The `user` profile needed to set custom system-wide settings in GNOME.
      # Also, this is a private option so take precautions with this.
      profiles.user = pkgs.writeTextFile {
        name = "a-happy-gnome";
        text = ''
          user-db:user
          system-db:${name}-conf
        '';
      };
    };

    xdg.mime = {
      enable = true;
      defaultApplications = {
        # Default application for web browser.
        "text/html" = "re.sonny.Junction.desktop";

        # Default handler for all files. Not all applications will
        # respect it, though.
        "x-scheme-handler/file" = "re.sonny.Junction.desktop";

        # Default handler for directories.
        "inode/directory" = "re.sonny.Junction.desktop";
      };
    };

    environment.systemPackages = with pkgs; [
      # The preferred terminal.
      cfg.terminal

      # The application menu.
      junction

      # It is required for custom menus in extensions.
      gnome-menus

      # A third-party extension manager.
      gnome-extension-manager

      # GNOME search providers.
      gnome-search-provider-recoll
    ] ++ cfg.shellExtensions ++ cfg.extraApps;
  };
}
