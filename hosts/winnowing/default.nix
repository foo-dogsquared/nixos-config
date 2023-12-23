{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/profiles/minimal.nix"

    (lib.private.mapHomeManagerUser "foo-dogsquared" {
      extraGroups = [
        "adbusers"
        "wheel"
        "audio"
        "docker"
        "podman"
        "networkmanager"
        "wireshark"
      ];
      hashedPassword =
        "$y$j9T$UFzEKZZZrmbJ05CTY8QAW0$X2RD4m.xswyJlXZC6AlmmuubPaWPQZg/Q1LDgHpXHx1";
      isNormalUser = true;
      createHome = true;
      home = "/home/foo-dogsquared";
      description = "Gabriel Arazas";
    })
  ];

  wsl = {
    enable = true;
    defaultUser = "foo-dogsquared";
    nativeSystemd = true;
  };

  programs.bash.loginShellInit = "nixos-wsl-welcome";

  # Setting the development environment mainly for container-related work.
  profiles.dev.enable = true;
  profiles.dev.containers.enable = true;
}
