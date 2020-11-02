{ config, options, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.hardware.audio;
in {
  options.modules.hardware.audio = let
    mkBoolDefault = bool:
      mkOption {
        type = types.bool;
        default = false;
      };
    in {
      enable = mkBoolDefault false;
      jack.enable = mkBoolDefault false;
  };

  config = mkIf cfg.enable {
    # Enable JACK for the most serious audio applications.
    # services.jack = {
    #   jackd.enable = true;
    #   alsa.enable = false;
    #   loopback = { enable = true; };
    # };

    hardware.pulseaudio.package =
      pkgs.pulseaudio.override { jackaudioSupport = true; };

    # Required when enabling JACK daemon.
    # USERADD: When the other users also want to take advantage of the audio systems.
    my.user.extraGroups = [ "audio" "jackaudio" ];

    # Add the sequencer and the MIDI kernel module.
    boot.kernelModules = [ "snd-seq" "snd-rawmidi" ];
  };
}
