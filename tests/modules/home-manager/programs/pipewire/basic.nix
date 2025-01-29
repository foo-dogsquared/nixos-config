{ lib, ... }:

{
  programs.pipewire = {
    enable = true;
    settings = {
      hello = "world";
      what = true;
      oh.wow = "!!!";
    };
    overrides = {
      noisetorch = {
        bawk-bawk = true;
        reduce-noise-level = 0.5;
      };
      nvidia-ai-what = {
        hawk-hawk = true;
        reduce-muffled-sounds = true;
        noise-gate = 5.6;
        abc = [ "d" "e" "f" ];
      };
    };
  };

  test.stubs.pipewire = { };

  nmt.script = ''
    assertFileExists home-files/.config/pipewire/pipewire.conf
    assertFileExists home-files/.config/pipewire/pipewire.conf.d/noisetorch.conf
    assertFileExists home-files/.config/pipewire/pipewire.conf.d/nvidia-ai-what.conf
  '';
}
