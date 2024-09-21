{ config, lib, pkgs, foodogsquaredLib, bahaghariLib, ... }@attrs:

let
  inherit (bahaghariLib.tinted-theming) importScheme;
  userCfg = config.users.foo-dogsquared;
in
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
      vs-code.enable = true;

      custom-homepage = {
        enable = true;
        sections = lib.mkMerge [
          # Merge the upstream since any new files will be overridden. It also
          # allows us to attach data to it such as new links to the hardcoded
          # sections.
          (lib.importTOML "${config.users.foo-dogsquared.programs.custom-homepage.package.src}/data/foodogsquared-homepage/links.toml")

          {
            services = {
              name = "Local services";
              flavorText = "For your local productivity";
              textOnly = true;
              weight = (-50);

              icon = {
                iconset = "material-design-icons";
                name = "room-service";
              };
            };
          }

          (lib.mkIf config.services.archivebox.webserver.enable {
            services.links = lib.singleton {
              url = "http://localhost:${builtins.toString config.state.ports.archivebox-webserver.value}";
              text = "Archive webserver";
            };

            YOHOOHOOHOOHOO.links = lib.mkBefore (lib.singleton {
              url = "http://localhost:${builtins.toString config.state.ports.archivebox-webserver.value}";
              text = "ArchiveBox webserver";
            });
          })

          (lib.mkIf (attrs.nixosConfig.suites.filesystem.setups.archive.enable or false) {
            YOHOOHOOHOOHOO.links = lib.mkBefore (lib.singleton {
              url = "file://${attrs.nixosConfig.state.paths.archive}";
              text = "Personal archive";
            });
          })
        ];
      };
    };

    services.backup.enable = true;

    setups = {
      desktop.enable = true;
      development.enable = true;
      fonts.enable = true;
      music.enable = true;
      music.mpd.enable = true;
      music.spotify.enable = true;
      research.enable = true;
    };
  };

  # Set the profile picture. Most of the desktop environments should support
  # this.
  home.file.".face".source = ./files/logo.png;

  # The keyfile required to decrypt the secrets.
  sops.age.keyFile = "${config.xdg.configHome}/age/user";

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

  # Holding these in for whatever reason.
  state.packages = {
    diff = pkgs.diffoscope;
    pager = config.programs.bat.package;
    editor =
      if userCfg.programs.nixvim.enable then
        config.programs.nixvim.finalPackage
      else
        config.programs.neovim.package;
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

  _module.args.defaultScheme = "bark-on-a-tree";

  bahaghari.tinted-theming.schemes = {
    bark-on-a-tree =
      importScheme ./files/tinted-theming/base16/bark-on-a-tree.yaml;
    albino-bark-on-a-tree =
      importScheme ./files/tinted-theming/base16/albino-bark-on-a-tree.yaml;
  };
}
