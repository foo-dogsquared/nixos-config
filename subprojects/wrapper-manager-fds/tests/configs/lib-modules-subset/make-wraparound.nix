{ config, lib, pkgs, wrapperManagerLib, ... }:

let
  inherit (wrapperManagerLib) makeWraparound;
in
{
  build.variant = "shell";
  wrappers.tmux = makeWraparound {
    under = lib.getExe' pkgs.boxxy "boxxy";
    underFlags = [ "--rule" "~/.tmux.conf:~/.config/tmux/tmux.conf" ];
    underSeparator = "--";

    arg0 = lib.getExe' pkgs.tmux "tmux";
  };

  build.extraPassthru.wrapperManagerTests = {
    actuallyBuilt =
      let
        wrapper = config.build.toplevel;
        tmux = lib.getExe' wrapper "tmux";
      in
      pkgs.runCommand "wrapper-manager-tmux-actually-built" { } ''
        [ -x "${tmux}" ] && touch $out
      '';
  };
}
