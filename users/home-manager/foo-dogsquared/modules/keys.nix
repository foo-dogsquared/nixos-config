{ config, lib, pkgs, ... }:

{
  # My SSH client configuration. It is encouraged to keep matches and extra
  # configurations included in a separate `config.d/` directory. This enables
  # it to easily backup the certain files which is most likely what we're
  # mostly configuring anyways.
  programs.ssh = {
    enable = true;
    includes = [ "config.d/*" ];
    extraConfig = ''
      AddKeysToAgent confirm 15m
      ForwardAgent no
    '';
  };

  # My GPG client. It has to make sure the keys are not generated and has to be
  # backed up somewhere.
  #
  # If you want to know how to manage GPG PROPERLY for the nth time, read the
  # following document:
  # https://alexcabal.com/creating-the-perfect-gpg-keypair
  programs.gpg = {
    enable = true;

    # This is just made to be a starting point, per se.
    mutableKeys = true;
    mutableTrust = true;

    settings = {
      default-key = "0xADE0C41DAB221FCC";
      keyid-format = "0xlong";
      with-fingerprint = true;
      no-comments = false;
    };
  };
}
