# The default shared configuration for the entire list of hosts for
# this cluster. Take note to only set as minimal configuration as
# possible since we're also using this with the stable version of
# nixpkgs.
{ options, lib, pkgs, ... }: {
  # Initialize some of the XDG base directories ourselves since it is
  # used by NIX_PROFILES to properly link some of them.
  environment.sessionVariables = {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
  };

  # Find Nix files with these! Even if nix-index is already enabled, it
  # is better to make it explicit.
  programs.command-not-found.enable = false;
  programs.nix-index.enable = true;

  # Improve the state of documentation (even if it's just a bit out-of-date).
  documentation.man.generateCaches = true;

  # BOOOOOOOOOOOOO! Somebody give me a tomato!
  services.xserver.excludePackages = with pkgs; [ xterm ];

  # Append with the default time servers. It is becoming more unresponsive as
  # of 2023-10-28.
  networking.timeServers =
    [ "europe.pool.ntp.org" "asia.pool.ntp.org" "time.cloudflare.com" ]
    ++ options.networking.timeServers.default;

  # Disable channel state files. This shouldn't break any existing
  # programs as long as we manage them NIX_PATH ourselves.
  nix.channel.enable = lib.mkDefault false;

  # Please clean your temporary crap.
  boot.tmp.cleanOnBoot = lib.mkDefault true;

  # We live in a Unicode world and dominantly English in technical fields so we'll
  # have to go with it.
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  # Enabling some things for sops.
  programs.gnupg.agent = lib.mkDefault {
    enable = true;
    enableSSHSupport = true;
  };
  services.openssh.enable = lib.mkDefault true;

  # It's following the 'nixpkgs' flake input which should be in unstable
  # branches. Not to mention, most of the system configurations should
  # have this attribute set explicitly by default.
  system.stateVersion = lib.mkDefault "23.11";
}
