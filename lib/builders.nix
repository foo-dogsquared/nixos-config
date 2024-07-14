{ pkgs, lib, self }:

{
  /* Create an XDG MIME Association listing. This should also take care of
     generating desktop-specific mimeapps.list if `desktopName` is given. The
     given desktop name is already assumed to be in suitable casing which is
     typically in lowercase ASCII.
  */
  makeXDGMimeAssociationList = {
    desktopName ? "",
    addedAssociations ? { },
    removedAssociations ? { },
    defaultApplications ? { },
  }:
    pkgs.writeTextFile {
      name = "xdg-mime-associations";
      text =
        # Non-desktop-specific mimeapps.list are only allowed to specify
        # default applications.
        lib.generators.toINI { } ({
          "Default Applications" = defaultApplications;
        } // (lib.optionalAttrs (desktopName == "") {
          "Added Associations" = addedAssociations;
          "Removed Associations" = removedAssociations;
        }));
      destination = "/share/applications/${lib.optionalString (desktopName != "") "${desktopName}-"}mimeapps.list";
    };

  /* Create an XDG Portals configuration with the given desktop name and its
     configuration. Similarly, the given desktop name is assumed to be already
     in its suitable form of a lowercase ASCII.
  */
  makeXDGPortalConfiguration = {
    desktopName ? "common",
    config,
  }:
    pkgs.writeTextFile {
      name = "xdg-portal-config-${desktopName}";
      text = lib.generators.toINI { } config;
      destination = "/share/xdg-desktop-portal/${lib.optionalString (desktopName != "common") "${desktopName}-"}portals.conf";
    };

  /* Create an XDG desktop entry file. Unlike the `makeDesktopItem`, it doesn't
     have a required schema as long as it is valid data to be converted to.
     Furthermore, the validation process can be disabled in case you want to
     create something like an entry for a desktop session.
  */
  makeXDGDesktopEntry = {
    name,
    config,
    validate ? true,
    destination ? "/share/applications/${name}.desktop",
  }:
    pkgs.writeTextFile {
      name = "xdg-desktop-entry-${name}";
      text = lib.generators.toINI {
        listsAsDuplicateKeys = false;
        mkKeyValue = lib.generators.mkKeyValueDefault {
          mkValueString = v:
            if lib.isList v then lib.concatStringsSep ";" v
            else lib.generators.mkValueStringDefault { } v;
        } "=";
      } config;
      inherit destination;
      checkPhase =
        lib.optionalString validate
          ''
            ${lib.getExe' pkgs.desktop-file-utils "desktop-file-validate"} "$target"
          '';
    };
}
