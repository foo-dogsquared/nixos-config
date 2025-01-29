# Themes are your graphical sessions. It also contains your aesthetics even
# specific workflow and whatnots. You can also show your desktop being
# modularized like this.
{ lib, ... }:

{
  options.workflows.enable = lib.mkOption {
    type = with lib.types; listOf (enum [ ]);
    default = [ ];
    description = ''
      A list of workflows to be enabled.

      Each workflow basically represents a way to interact with your computer
      such as a typical complete desktop environment or a minimalistic desktop
      featuring a standalone window manager with a custom status bar.

      While there's no set convention as to what each workflow should be,
      workflows usually contain a complete graphical session configured inside
      of it. A couple of exceptions are, for example, a complete standalone
      tmux configuration where it can be used inside of a TTY or something like
      that.
    '';
    example = [ "a-happy-gnome" "knome" "horizontal-hunger" ];
  };

  imports = [ ./a-happy-gnome ./knome ];
}
