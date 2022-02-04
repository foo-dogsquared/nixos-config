{ self, lib, config, pkgs, inputs, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  isoImage = {
    isoBaseName = "bootstrap-${config.networking.hostName}";
    contents = [{
      source = self;
      target = "/bootstrap/";
    }];
    storeContents = [
      self.devShell.${config.nixpkgs.system}
    ] ++ builtins.attrValues inputs;
  };

  networking.hostName = "bootstrap";
  boot.supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];

  nix = {
    gc.automatic = true;
    optimise.automatic = true;

    # Please see `nix-conf.5` manual for more details.
    settings = {
      # All to make improvement for using Nix.
      trusted-users = [ "root" "@wheel" ];
      allow-import-from-derivation = true;
      allow-dirty = true;
      auto-optimise-store = true;
      sandbox = true;

      # Set several binary caches.
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
        "https://foo-dogsquared.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "foo-dogsquared.cachix.org-1:/2fmqn/gLGvCs5EDeQmqwtus02TUmGy0ZlAEXqRE70E="
      ];
    };
  };

  users.users = {
    root.password = "";

    nixos = {
      password = "nixos";
      description = "default";
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
  };

  environment.systemPackages = with pkgs; [
    binutils
    coreutils
    moreutils
    whois
    jq
    git
    manix

    # The coreutils replacement.
    ripgrep
    fd
    bat
  ];

  boot.loader.systemd-boot.enable = true;
}
