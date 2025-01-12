{ lib, writeTextFile, desktop-file-utils }:

/* Create an XDG desktop entry file. Unlike the `makeDesktopItem`, it doesn't
   have a required schema as long as it is valid data to be converted to.
   Furthermore, the validation process can be disabled in case you want to
   create something like an entry for a desktop session.
*/
{
# Name of the desktop entry. Only used as part of the package name and the
# default value of the destination path.
name,

# Nix-representable data to be exported as the desktop entry.
config,

# Add a validation check for the exported desktop entry.
validate ? true,

# Destination path relative to the output path.
destination ? "/share/applications/${name}.desktop", }:

writeTextFile {
  name = "xdg-desktop-entry-${name}";
  text = lib.generators.toINI {
    listsAsDuplicateKeys = false;
    mkKeyValue = lib.generators.mkKeyValueDefault {
      mkValueString = v:
        if lib.isList v then
          lib.concatStringsSep ";" v
        else
          lib.generators.mkValueStringDefault { } v;
    } "=";
  } config;
  inherit destination;
  checkPhase = lib.optionalString validate ''
    ${lib.getExe' desktop-file-utils "desktop-file-validate"} "$target"
  '';
}
