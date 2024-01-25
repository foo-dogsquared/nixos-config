# Enable the preferred audio workflow.
{ lib, ... }:

{
  security.rtkit.enable = lib.mkDefault true;

  # The main preferred setup of our audio system.
  services.pipewire = {
    enable = lib.mkDefault true;

    # This is enabled by default but I want to explicit since
    # this is my preferred way of managing anyways.
    wireplumber.enable = true;

    # Enable all the bi-...bridges.
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # This is based from https://jackaudio.org/faq/linux_rt_config.html.
  security.pam.loginLimits = [
    {
      domain = "@audio";
      type = "-";
      item = "rtprio";
      value = "95";
    }
    {
      domain = "@audio";
      type = "-";
      item = "memlock";
      value = "unlimited";
    }
  ];
}
