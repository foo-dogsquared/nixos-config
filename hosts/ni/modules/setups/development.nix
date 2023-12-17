{ config, lib, pkgs, ... }:

let
  hostCfg = config.hosts.ni;
  cfg = hostCfg.setups.development;
in
{
  options.hosts.ni.setups.development.enable =
    lib.mkEnableOption "software development setup";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      # Bring all of the software development goodies.
      profiles.dev = {
        enable = true;
        extras.enable = true;
        virtualization.enable = true;
        neovim.enable = true;
      };

      environment.systemPackages = with pkgs; [
        # For debugging build environments in Nix packages.
        cntr
      ];

      # Enable the terminal emulator of choice.
      programs.wezterm.enable = true;

      # Enable them debugging your mobile tracker.
      programs.adb.enable = true;

      # Installing Guix within NixOS. Now that's some OTP rarepair material right
      # there.
      services.guix = {
        enable = true;
        gc = {
          enable = true;
          dates = "weekly";
        };
      };

      # Adding a bunch of emulated systems for cross-system building.
      boot.binfmt.emulatedSystems = [
        "aarch64-linux"
        "riscv64-linux"
      ];
    }

    # You'll be most likely having these anyways and even if this is disabled,
    # you most likely cannot use the system at all so WHY IS IT HERE?
    (lib.mkIf hostCfg.networking.enable {
      environment.systemPackages = with pkgs; [
        # Some sysadmin thingamajigs.
        openldap

        # Searchsploit.
        exploitdb
      ];

      # Be a networking doctor or something.
      programs.mtr.enable = true;

      # Wanna be a wannabe haxxor, kid?
      programs.wireshark.package = pkgs.wireshark;

      # Modern version of SSH.
      programs.mosh.enable = true;
    })
  ]);
}
