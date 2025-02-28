{ lib, writeTextFile }:

/* Create an XDG MIME Association listing. This should also take care of
   generating desktop-specific mimeapps.list if `desktopName` is given. The
   given desktop name is already assumed to be in suitable casing which is
   typically in lowercase ASCII.
*/
{
# An optional string containing the name of the desktop to be associated
# with.
desktopName ? "",

# Optional Nix-representable settings in INI format. Mutually exclusive with
# `addedAssociations`, `removedAssociations`, and `defaultApplications` and
# basically ignores proper checking if set.
settings ? { },

# Applications to be put in `Added Associations`. This is not set when the
# database is desktop-specific (when the `desktopName` is non-empty.)
addedAssociations ? { },

# Associations to be put in `Removed Associations` in the file. Similar to
# `addedAssociations`, this will not be added when it is desktop-specific.
removedAssociations ? { },

# Set of applications to be opened associated with the MIME type.
defaultApplications ? { }, }:

writeTextFile {
  name = "xdg-mime-associations${
      lib.optionalString (desktopName != "") "-${desktopName}"
    }";
  text =
    # Non-desktop-specific mimeapps.list are only allowed to specify
    # default applications.
    lib.generators.toINI { } (
      if (settings != { }) then settings
      else {
        "Default Applications" = defaultApplications;
      } // (lib.optionalAttrs (desktopName == "") {
        "Added Associations" = addedAssociations;
        "Removed Associations" = removedAssociations;
      }));
  destination = "/share/applications/${
      lib.optionalString (desktopName != "") "${desktopName}-"
    }mimeapps.list";
}

