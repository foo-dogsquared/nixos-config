{ lib, pkgs, self }:

{
  # The gnome-session config files uses one from GLib. See the following link
  # at <https://docs.gtk.org/glib/struct.KeyFile.html> for details about the
  # keyfile formatting and possibly the Desktop Entry specification at
  # <https://freedesktop.org/wiki/Specifications/desktop-entry-spec>.
  glibKeyfile = {}: {
    type = with lib.types;
      let
        valueType = oneOf [ bool float int str (listOf valueType) ] // {
          description =
            "GLib keyfile atom (bool, int, float, string, or a list of the previous atoms)";
        };
      in attrsOf (attrsOf valueType);

    generate = name: value:
      pkgs.callPackage
      ({ lib, writeText }: writeText name (lib.generators.toDconfINI value));
  };
}
