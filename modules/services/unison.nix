# When enabled, this will periodically backup your stuff as configured in '$UNISON/default.prf' (or not with the 'flags' option).
{ config, options, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.services.unison;
in
{
  options.modules.services.unison = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    flags = mkOption {
      type = types.str;
      default = "";
    };
  };

  config = mkIf cfg.enable {
    my.home = {
      systemd.user.services.unison = {
        Unit = {
          Description = "Unison backup";
          Documentation = [ "https://www.cis.upenn.edu/~bcpierce/unison/docs.html" ];
        };

        Service = {
          ExecStart = "${(pkgs.unison.override { enableX11 = false; })}/bin/unison ${cfg.flags}";
          Environment = [ "UNISON=\"$XDG_DATA_HOME/unison\"" ];
          RestartSec = "2h";
        };

        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
  };
}
