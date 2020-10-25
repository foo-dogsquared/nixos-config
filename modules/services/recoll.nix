# When enabled, this will create a systemd service that creates a periodical Recoll index.
# For customization, you should write the config file at "$XDG_CONFIG_HOME/recoll".
{ config, options, lib, pkgs, ... }:

with lib;

let cfg = config.modules.services.recoll;
in {
  options.modules.services.recoll = {
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
      systemd.user.services.recoll = {
        Unit = {
          Description = "Recoll periodic index update";
          Documentation = [
            "man:recollindex.1"
            "https://www.lesbonscomptes.com/recoll/pages/documentation.html"
          ];
        };

        Service = {
          Environment = [ ''RECOLL_CONFDIR="$XDG_DATA_HOME/recoll"'' ];
          ExecStart = "${
              (pkgs.recoll.override { withGui = false; })
            }/bin/recollindex ${cfg.flags}";
        };

        Install = { WantedBy = [ "default.target" ]; };
      };

      # Make the service run every 4 hours (and still activate if it misses the interval).
      systemd.user.timers.recoll = {
        Unit = {
          Description = "Recoll periodic index update";
          Documentation = [
            "man:recollindex.1"
            "https://www.lesbonscomptes.com/recoll/pages/documentation.html"
          ];
        };

        Timer = {
          OnCalendar = "*-*-* 0/4:00:00";
          Persistent = true;
        };

        Install = { WantedBy = [ "default.target" ]; };
      };
    };
  };
}
