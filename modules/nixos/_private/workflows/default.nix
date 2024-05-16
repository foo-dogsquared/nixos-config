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
    '';
  };

  imports = [
    ./a-happy-gnome
    ./knome
  ];
}
