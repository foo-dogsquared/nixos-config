# A module that automates setting up agenix for your system.
{ inputs, lib, options, config, system, ... }:

let cfg = config.profiles.agenix;
in {
  options.profiles.agenix.enable =
    lib.mkEnableOption "agenix-related config on your system";

  imports = [ inputs.agenix.nixosModules.age ];
  config = lib.mkIf cfg.enable {
    # Enable all relevant services.
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    services.sshd.enable = true;
    services.openssh.enable = true;
  };
}
