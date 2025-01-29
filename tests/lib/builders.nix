{ pkgs, lib, self }:

let sampleDesktopName = "horizontal-hunger";
in lib.runTests {
  testsBuilderMakeSampleXDGAssociationList = {
    expr = let
      xdgAssociations = self.builders.makeXDGMimeAssociationList {
        defaultApplications = { "application/pdf" = "firefox.desktop"; };
      };
    in builtins.readFile "${xdgAssociations}/share/applications/mimeapps.list";
    expected = builtins.readFile ./data/fixtures/xdg-mime-sample-mimeapps.list;
  };

  # This should only create the "Default Applications" section of the
  # specific-desktop mimeapps.list.
  testsBuilderMakeSampleDesktopSpecificXDGAssociationList = {
    expr = let
      xdgAssociations = self.builders.makeXDGMimeAssociationList {
        desktopName = sampleDesktopName;
        defaultApplications = { "application/pdf" = "firefox.desktop"; };
      };
    in builtins.readFile
    "${xdgAssociations}/share/applications/${sampleDesktopName}-mimeapps.list";
    expected = builtins.readFile
      ./data/fixtures/xdg-mime-sample-desktop-specific-mimeapps.list;
  };

  testsBuilderMakeSampleXDGPortalCommonConfig = {
    expr = let
      xdgPortalConf = self.builders.makeXDGPortalConfiguration {
        config.preferred = {
          default = "gtk";
          "org.freedesktop.impl.portal.Screencast" = "gnome";
        };
      };
    in builtins.readFile
    "${xdgPortalConf}/share/xdg-desktop-portal/portals.conf";
    expected = builtins.readFile ./data/fixtures/xdg-portal.conf;
  };

  # We're just testing out if the destination is correct at this point.
  testsBuilderMakeSampleXDGPortalDesktopSpecificConfig = {
    expr = let
      xdgPortalConf = self.builders.makeXDGPortalConfiguration {
        desktopName = sampleDesktopName;
        config.preferred = {
          default = "gtk";
          "org.freedesktop.impl.portal.Screencast" = "gnome";
        };
      };
    in builtins.readFile
    "${xdgPortalConf}/share/xdg-desktop-portal/${sampleDesktopName}-portals.conf";
    expected = builtins.readFile ./data/fixtures/xdg-portal.conf;
  };

  # We're just testing out if the destination is correct at this point.
  testsBuilderMakeSampleXDGDesktopEntry = {
    expr = let
      xdgDesktopEntry = self.builders.makeXDGDesktopEntry {
        name = sampleDesktopName;
        validate = false;
        config = { "Desktop Entry".Exec = "Hello"; };
      };
    in builtins.readFile
    "${xdgDesktopEntry}/share/applications/${sampleDesktopName}.desktop";
    expected = builtins.readFile ./data/fixtures/xdg-desktop-entry.desktop;
  };

  # We're just testing out if the destination is correct at this point.
  testsBuilderMakeSampleDesktopSessionFile = {
    expr = let
      xdgDesktopEntry = self.builders.makeXDGDesktopEntry {
        name = sampleDesktopName;
        validate = false;
        destination = "/share/wayland-sessions/${sampleDesktopName}.desktop";
        config = {
          "Desktop Entry" = {
            Exec = "Hello";
            DesktopNames = [ "GNOME" "Sway" ];
          };
        };
      };
    in builtins.readFile
    "${xdgDesktopEntry}/share/wayland-sessions/${sampleDesktopName}.desktop";
    expected = builtins.readFile ./data/fixtures/xdg-desktop-session.desktop;
  };
}
