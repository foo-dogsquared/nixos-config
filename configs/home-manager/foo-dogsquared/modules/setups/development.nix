{ config, lib, pkgs, options, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.setups.development;
in
{
  options.users.foo-dogsquared.setups.development.enable =
    lib.mkEnableOption "foo-dogsquared's software development setup";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      users.foo-dogsquared.programs = {
        shell.enable = lib.mkDefault true;
        git.enable = lib.mkDefault true;
        keys.gpg.enable = true;
        keys.ssh.enable = true;
        terminal-multiplexer.enable = lib.mkDefault true;
      };

      suites.dev = {
        enable = true;
        extras.enable = true;
        coreutils-replacement.enable = true;
        shell.enable = true;
        servers.enable = true;
      };

      programs.neovim = lib.mkIf (!config.programs.nixvim.enable) {
        enable = true;
        package = pkgs.neovim-nightly;
        vimAlias = true;
        vimdiffAlias = true;

        withNodeJs = true;
        withPython3 = true;
        withRuby = true;
      };

      systemd.user.sessionVariables = {
        MANPAGER = "nvim +Man!";
        EDITOR = "nvim";
      };

      home.packages = with pkgs; [
        cachix # Compile no more by using someone's binary cache!
        regex-cli # Save some face of confusion for yourself.
        dt # Get that functional gawk.
        recode # Convert between different encodings.
      ];
    }

    (lib.mkIf userCfg.programs.git.enable {
      home.packages = with pkgs; [
        diffoscope # An oversized caffeine grinder.
        meld # Make a terminal dweller melt.
      ];

      programs.git.extraConfig = {
        difftool.prompt = false;
        diff.tool = "diffoscope";
        diff.guitool = "meld";

        # Yeah, let's use this oversized diff tool, shall we?
        # Also, this config is based from this tip.
        # https://lists.reproducible-builds.org/pipermail/diffoscope/2016-April/000193.html
        difftool."diffoscope".cmd = ''
          if [[ $LOCAL = /dev/null ]]; then diffoscope --new-file $REMOTE; else diffoscope $LOCAL $REMOTE; fi
        '';

        difftool."diffoscope-html".cmd = ''
          if [[ $LOCAL = /dev/null ]]; then diffoscope --new-file $REMOTE --html - | cat; else diffoscope $LOCAL $REMOTE --html - | cat; fi
        '';
      };
    })

    (lib.mkIf (userCfg.setups.desktop.enable && pkgs.stdenv.isLinux) {
      home.packages = with pkgs; [
        bustle # Hustle with some d-bus Bustle.
        dfeet # Some GNOME dev probably developed this.
      ];
    })
  ]);
}
