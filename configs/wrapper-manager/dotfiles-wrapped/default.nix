# All of the programs with my outside dotfiles from
# https://github.com/foo-dogsquared/dotfiles. Pretty nifty for me to have,
# yeah? This should work on both NixOS and non-NixOS system considering that
# parts from the config are conditionally setting up NixGL wrapping. Though,
# you have to use NixOS systems in order to actually use it. We probably should
# have a specialized launcher for this.
let
  sources = import ./npins;
in
{ lib, pkgs, wrapperManagerLib, ... }@moduleArgs:

let
  inherit (sources) dotfiles nixgl;

  getDotfiles = path: "${dotfiles}/${path}";
  isInNonNixOS = !(moduleArgs ? nixosConfig);

  wrapNixGL = arg0:
    if isInNonNixOS then {
      nixgl.enable = true;
      nixgl.wraparound.arg0 = arg0;
    } else {
      inherit arg0;
    };
in
{
  # This wrapper needs runtime expansion which is not possible with binary
  # wrappers.
  build.variant = "shell";

  nixgl.src = nixgl;

  wrappers.wezterm = lib.mkMerge [
    {
      env.WEZTERM_CONFIG_FILE.value = getDotfiles "wezterm/wezterm.lua";
    }

    (wrapNixGL (lib.getExe' pkgs.wezterm "wezterm"))
  ];

  wrappers.kitty = lib.mkMerge [
    {
      env.KITTY_CONFIG_DIRECTORY.value = getDotfiles "kitty";
    }

    (wrapNixGL (lib.getExe' pkgs.kitty "kitty"))
  ];

  wrappers.nvim = {
    env.VIM.value = getDotfiles "nvim";
    arg0 = lib.getExe' pkgs.neovim "nvim";
  };

  # Trying to create a portable Doom Emacs.
  wrappers.emacs = lib.mkMerge [
    {
      env.EMACSDIR.value = builtins.toString sources.doom-emacs;
      env.DOOMDIR.value = getDotfiles "emacs";
      env.DOOMPROFILELOADFILE.value = lib.escapeShellArg "$XDG_CACHE_HOME/doom/profiles.el";

      # TODO: This will be removed in Doom Emacs 3.0 as far as I can tell so we'll
      # remove it once that happens.
      env.DOOMLOCALDIR.value = lib.escapeShellArg "$XDG_CONFIG_HOME/emacs/";

      pathAdd = wrapperManagerLib.getBin [
        sources.doom-emacs
      ];
    }

    (wrapNixGL (lib.getExe' pkgs.emacs "emacs"))
  ];

  build.extraSetup = ''
    install -Dm0755 ${getDotfiles "bin"}/* -t $out/bin
  '';
}
