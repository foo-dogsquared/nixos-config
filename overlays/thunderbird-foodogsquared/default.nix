{ final, prev }:


{
  thunderbird-foodogsquared = with prev; wrapThunderbird thunderbird {
    extraPolicies = {
      AppsAutoUpdate = false;
      DisableAppUpdate = false;

      ExtensionSettings = let
        thunderbirdAddon = name:
          "https://addons.thunderbird.net/thunderbird/downloads/latest/${name}/latest.xpi";

        extensions = {
          "uBlock0@raymondhill.net" = {
            installation_mode = "force_installed";
            installation_url = thunderbirdAddon "ublock-origin";
          };

          "{e6696d02-466a-11e3-a162-04e36188709b}".installation_url = thunderbirdAddon "eds-calendar-integration";
          "quickfolders@curious.be".installation_url = thunderbirdAddon "quickfolders-tabbed-folders";
        };

        applyInstallationMode = name: value:
          lib.nameValuePair name (value //
            (lib.optionalAttrs
              (! (lib.hasAttrByPath [ "installation_mode" ] value))
              { installation_mode = "normal_installed"; }));
      in
        lib.mapAttrs' applyInstallationMode extensions;

      OfferToSaveLoginsDefault = false;
      PasswordManagerEnabled = false;
    };
  };
}
