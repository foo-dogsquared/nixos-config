{ config, lib, pkgs, ... }:

let
  workflowName = "one.foodogsquared.AHappyGNOME";
  cfg = config.workflows.workflows.${workflowName};

  requiredApps = with pkgs;
    [
      # The application menu.
      junction

      # The application launcher for your one-handed keyboard handling (the
      # other is in the mouse, if you're thinking something else).
      kando

      # Valent...ines 'tis season to share... phone data or something.
      valent
    ];

  # All of the shell extensions plus their required extensions.
  shellExtensions' = cfg.shellExtensions ++ (with pkgs.gnomeExtensions; [
    valent
    kando-integration
    paperwm
  ]);

  workspaceSubmodule = { name, ... }: {
    freeformType = with lib.types; attrsOf anything;
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        default = name;
        description = "The formal name of the workspace.";
        example = "Software development";
      };
    };
  };
in {
  options.workflows.enable =
    lib.mkOption { type = with lib.types; listOf (enum [ workflowName ]); };

  options.workflows.workflows.${workflowName} = {
    shellExtensions = lib.mkOption {
      type = with lib.types; listOf package;
      description = ''
        A list of extra GNOME Shell extensions to be included. Take note the
        package should contain `passthru.extensionUuid` to be used for enabling
        the extensions.
      '';
      default = with pkgs.gnomeExtensions; [
        alphabetical-app-grid
        appindicator
        arcmenu
        burn-my-windows
        caffeine
        fly-pie
        just-perfection
        kimpanel
        light-style
        mpris-label
        runcat
        windownavigator
      ];
      example = lib.literalExpression ''
        with pkgs.gnomeExtensions; [
          appindicator
          gsconnect
          runcat
          just-perfection
        ];
      '';
    };

    extraApps = lib.mkOption {
      type = with lib.types; listOf package;
      description = "A list of applications to be included in the theme.";
      default = with pkgs; [
        adw-gtk3 # A nice theme for GTK3.
        amberol # An unambitious music player.
        authenticator # 2-factor codes for 2-factor storages.
        blanket # Zen...
        dialect # Your gateway to polyglotting.
        eyedropper # Some nice eyedropper tool.
        flowtime # Some nice timer for those overworking.
        fractal # Your gateway to the matrix.
        gnome-decoder # Go with them QR codes.
        gnome-frog # Graphical OCR with Tesseract that I always wanted.
        gnome-solanum # Cute little matodor timers.
        dconf-editor # A saner version of Windows registry.
        gnome-boxes # Virtual machines, son.
        mission-center # It is your duty to monitor your system.
        polari # Your gateway to one of the most hidden and cobweb-ridden parts of the internet. ;)
        gradience # Make it rain!
        handbrake # Take a break from those custom ffmpeg conversion scripts.
        shortwave # Yer' humble internet radio.
        symbolic-preview # Them symbols... it's important.
        gtranslator # It's not a Google translator app, I'll tell you that.
        tangram # Your social media manager, probably.
        ymuse # I muse with a simple MPD client.
        gnome-secrets # Feel the secureness, O Keeper of Secrets.

        gnome-backgrounds # Default backgrounds.

        gnome-menus # It is required for custom menus in extensions.
        gnome-extension-manager # The cooler GNOME extensions app.
        gnome-search-provider-recoll # This is here for some reason.

        # Nautilus extensions
        nautilus-annotations
        nautilus-open-any-terminal

        # Extra background images.
        fedora-backgrounds.f38
        fedora-backgrounds.f37
      ];
      example = lib.literalExpression ''
        with pkgs; [ gnome.polari ];
      '';
    };

    disableSearchProviders = lib.mkOption {
      type = with lib.types;
        listOf (coercedTo str (lib.removeSuffix ".desktop") str);
      description = ''
        A list of the application filenames (without the `.desktop` part) where
        its GNOME Shell search provider is to be disabled.

        By default, it disables some of the search providers from the default
        list of applications in
        {option}`workflows.workflows.${workflowName}.extraApps`.
      '';
      default = [
        "org.gnome.seahorse.Application"
        "org.gnome.Photos"
        "org.gnome.Epiphany"
        "app.drey.Dialect"
        "com.belmoussaoui.Authenticator"
      ];
      apply = lib.map (x: "${x}.desktop");
    };

    disableNotifications = lib.mkOption {
      type = with lib.types; listOf str;
      description = ''
        A list of identifiers of the application's notification to be disabled
        within GNOME Shell.

        By default, it just list a few from the default value of
        {option}`workflows.workflows.${workflowName}.extraApps`.
      '';
      default = [
        "re-sonny-tangram"
        "org-gnome-polari"
        "io-github-hexchat"
        "org-gnome-evolution-alarm-notify"
        "thunderbird"
      ];
    };

    kando = {
      extraArgs = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
        description = ''
          A list of extra arguments to be added to Kando autostart service.
        '';
        example = [ "--settings" ];
      };
    };

    paperwm = {
      workspaces = lib.mkOption {
        type = with lib.types; attrsOf (submodule workspaceSubmodule);
        default = { };
        description = ''
          A set of workspaces and their properties for PaperWM.
        '';
        example = lib.literalExpression ''
          {
            media = {
              name = "Media";
              index = lib.gvariant.mkInt32 0;
              color = "rgb(98,160,234)";
            };

            dev = {
              name = "Software dev't";
              index = lib.gvariant.mkInt32 1;
              color = "#99c1f1";
            };
          }
        '';
      };

      enablePresetWorkspaces = lib.mkEnableOption "preset workspace options for PaperWM" // {
        default = true;
      };

      enableStaticWorkspace = lib.mkEnableOption "static workspaces configuration for PaperWM" // {
        default = cfg.paperwm.enablePresetWorkspaces;
      };

      winprops = lib.mkOption {
        type = let
          inherit (lib.types) listOf;
          settingsFormat = pkgs.formats.json { };
        in listOf (settingsFormat.type);
        description = ''
          A list of default winprops settings for PaperWM.
        '';
        default = [ ];
        example = lib.literalExpression ''
          [
            {
              wm_class = "Firefox";
              preferredWidth = "100%";
              spaceIndex = 0;
            }

            {
              wm_class = "org.wezfurlong.wezterm";
              preferredWidth = "100%";
              spaceIndex = 1;
            }

            {
              wm_class = "Spotify";
              title = "Spotify Premium";
              spaceIndex = 0;
            }
          ]
        '';
      };

      enablePresetWinprops = lib.mkEnableOption null // {
        default = true;
        description = ''
          Whether to enable preset winprops for common programs.

          ::: {.note}
          This depends if the preset workspaces
          ({option}`workspaces.workspaces.${workflowName}.paperwm.enablePresetWorkspaces`)
          is enabled.
          :::
        '';
      };
    };
  };

  config = lib.mkIf (lib.elem workflowName config.workflows.enable) {
    assertions = [
      {
        assertion = !cfg.paperwm.enablePresetWinprops || cfg.paperwm.enablePresetWorkspaces;
        message = ''
          {option}`workflows.workflows.${workflowName}.paperwm.enablePresetWinprops`
          option requires
          {option}`workflows.workflows.${workflowName}.paperwm.enablePresetWorkspaces`
          to be enabled.
        '';
      }
    ];

    # Enable GNOME.
    services.xserver = {
      enable = true;
      desktopManager.gnome.enable = true;
    };

    xdg.autostart.entries = {
      "${workflowName}-kando" = {
        desktopName = "Kando";
        exec = "${lib.getExe pkgs.kando} --gapplication-service ${lib.concatStringsSep " " cfg.kando.extraArgs}";
        icon = "kando";
        genericName = "Pie Menu";
      };
    };

    workflows.workflows.${workflowName} = {
      paperwm.workspaces = lib.mkIf cfg.paperwm.enablePresetWorkspaces {
        media = {
          name = "Media";
          index = lib.gvariant.mkInt32 0;
          color = "#99c1f1"; # GNOME Blue 1
        };

        research = {
          name = "Research";
          index = lib.gvariant.mkInt32 1;
          color = "#613583"; # GNOME Purple 5
        };

        dev = {
          name = "Software dev't";
          index = lib.gvariant.mkInt32 2;
          color = "#1c71d8"; # GNOME Blue 4
        };

        creative = {
          name = "Creative work";
          index = lib.gvariant.mkInt32 3;
          color = "#f8e45c"; # GNOME Yellow 2
        };

        work = {
          name = "Work";
          index = lib.gvariant.mkInt32 4;
          color = "#ff7800"; # GNOME Orange 3
        };
      };

      paperwm.winprops =
        let
          wmIndexOf = name: cfg.paperwm.workspaces.${name}.index.value;
        in
        lib.optionals (cfg.paperwm.enablePresetWinprops) [
          {
            wm_class = "re.sonny.Junction";
            scratch_layer = true;
          }
        ]
        ++ lib.optionals config.programs.steam.enable [
          {
            wm_class = "steam";
            spaceIndex = wmIndexOf "media";
          }
        ]
        ++ lib.optionals config.programs.chromium.enable [
          {
            wm_class = "chromium";
            spaceIndex = wmIndexOf "chromium";
          }
        ]
        ++ lib.optionals config.programs.firefox.enable [
          {
            wm_class = "firefox";
            spaceIndex = wmIndexOf "media";
          }
        ];
    };

    # All GNOME-related additional options.
    services.gnome = {
      core-os-services.enable = true;
      core-shell.enable = true;
      core-apps.enable = true;

      # It doesn't need to since we're not first-timers, yeah?
      gnome-initial-setup.enable = false;
    };

    # It makes Nix store directory read/write so no...
    services.packagekit.enable = false;

    # Bring all of the dconf keyfiles in there.
    programs.dconf = {
      enable = true;

      # In this case, we're using the default user dconf profile which is the
      # fallback for every dconf-using components. Pretty handy.
      profiles.user.databases = lib.singleton {
        # Get them keyfiles.
        keyfiles = [ ./config/dconf ];

        settings = lib.mkMerge [
          {
            "org/gnome/desktop/search-providers" = {
              disabled = cfg.disableSearchProviders;
            };
            "org/gnome/shell" = {
              enabled-extensions =
                lib.map (p: p.extensionUuid) shellExtensions';
            };

            "org/gnome/mutter" = {
              dynamic-workspaces = !cfg.paperwm.enableStaticWorkspace;
            };

            "org/gnome/desktop/wm/preferences" = {
              num-workspaces =
                let
                  workspaces = lib.attrNames cfg.paperwm.workspaces;
                in
                lib.gvariant.mkInt32 (lib.length workspaces);
            };
          }

          # Disable all of the messenger's notification (only the annoying
          # ones).
          (lib.pipe cfg.disableNotifications [
            (lib.map (app:
              lib.nameValuePair
              "org/gnome/desktop/notifications/application/${app}" {
                show-banners = false;
              }))

            lib.listToAttrs
          ])

          (lib.mkIf (cfg.paperwm.winprops != [ ]) {
            "org/gnome/shell/extensions/paperwm".winprops =
              lib.map lib.strings.toJSON cfg.paperwm.winprops;
          })

          (lib.mkIf (cfg.paperwm.workspaces != { }) (
            let
              mkWorkspaceConfig = name: value:
                lib.nameValuePair "org/gnome/shell/extensions/paperwm/workspaces/${name}" value;

              workspaces = lib.attrNames cfg.paperwm.workspaces;
            in
            {
              "org/gnome/shell/extensions/paperwm/workspaces".list = workspaces;
            }
            // lib.mapAttrs' mkWorkspaceConfig cfg.paperwm.workspaces
          ))
        ];
      };
    };

    xdg.autostart.enable = true;

    xdg.mime = {
      enable = true;
      desktops.gnome.defaultApplications = {
        # Default application for web browser.
        "text/html" = "re.sonny.Junction.desktop";

        # Default handler for all files. Not all applications will
        # respect it, though.
        "x-scheme-handler/file" = "re.sonny.Junction.desktop";

        # Default handler for directories.
        "inode/directory" = "re.sonny.Junction.desktop";
      };
    };

    environment.systemPackages = requiredApps ++ shellExtensions'
      ++ cfg.extraApps;
  };
}
