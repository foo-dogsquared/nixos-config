{ pkgs, lib, self }:

let
  # We're just using stub configurations instead.
  nixosConfig = {
    programs = {
      firefox = {
        enable = true;
      };
    };

    services = {
      pipewire = {
        enable = true;
        wireplumber.enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };
    };
  };

  hmConfig = {
    services = {
      activitywatch.enable = true;
      bleachbit = {
        enable = true;
        cleaners = [
          "firefox.cookies"
          "discord.cache"
        ];
      };
    };
  };

  hmConfig' = {
    inherit nixosConfig;
    osConfig = nixosConfig;
  } // hmConfig;
in
lib.runTests {
  testHomeManagerStandaloneEmpty = {
    expr = self.home-manager.hasNixOSConfigAttr { } [ "programs" "firefox" "enable" ] false;
    expected = false;
  };

  testHomeManagerStandalone = {
    expr = self.home-manager.hasNixOSConfigAttr hmConfig [ "programs" "firefox" "enable" ] false;
    expected = false;
  };

  testHomeManagerWithinNixOS = {
    expr = self.home-manager.hasNixOSConfigAttr hmConfig' [ "programs" "firefox" "enable" ] false;
    expected = true;
  };
}
