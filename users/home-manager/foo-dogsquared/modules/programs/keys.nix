{ config, lib, pkgs, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.programs.keys;
in
{
  options.users.foo-dogsquared.programs.keys = {
    ssh.enable = lib.mkEnableOption "foo-dogsquared's SSH config";
    gpg.enable = lib.mkEnableOption "foo-dogsquared's GPG config";
  };

  config = lib.mkMerge [
    # My SSH client configuration. It is encouraged to keep matches and extra
    # configurations included in a separate `config.d/` directory. This enables
    # it to easily backup the certain files which is most likely what we're
    # mostly configuring anyways.
    (lib.mkIf cfg.ssh.enable {
      programs.ssh = {
        enable = true;
        includes = [ "config.d/*" ];
        extraConfig = ''
          AddKeysToAgent confirm 15m
          ForwardAgent no
          VisualHostKey yes
        '';
      };

      # Make all of the initial SSH identities configuration here. It should assume
      # I have other SSH identities configuration that are not committed here for
      # whatever reason.
      home.file.".ssh/config.d" = {
        source = ../../config/ssh;
        recursive = true;
      };
    })

    # My GPG client. It has to make sure the keys are not generated and has to be
    # backed up somewhere.
    #
    # If you want to know how to manage GPG PROPERLY for the nth time, read the
    # following document:
    # https://alexcabal.com/creating-the-perfect-gpg-keypair
    (lib.mkIf cfg.gpg.enable {
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
    })
  ];
}
