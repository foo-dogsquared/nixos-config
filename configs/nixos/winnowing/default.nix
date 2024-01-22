{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/profiles/minimal.nix"

    (lib.private.mapHomeManagerUser "winnow" {
      extraGroups = [
        "wheel"
        "docker"
        "podman"
      ];
      hashedPassword =
        "$y$j9T$UFzEKZZZrmbJ05CTY8QAW0$X2RD4m.xswyJlXZC6AlmmuubPaWPQZg/Q1LDgHpXHx1";
      isNormalUser = true;
      createHome = true;
      home = "/home/winnow";
      description = "Some type of bird";
    })
  ];

  wsl = {
    enable = true;
    defaultUser = "winnow";
    nativeSystemd = true;
  };

  programs.bash.loginShellInit = "nixos-wsl-welcome";

  programs.git.package = lib.mkForce pkgs.git;

  # Setting the development environment mainly for container-related work.
  suites.dev.enable = true;
  suites.dev.containers.enable = true;
}
