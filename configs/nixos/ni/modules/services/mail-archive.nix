{ config, lib, pkgs, ... }:

let
  hostCfg = config.hosts.ni;
  cfg = hostCfg.services.mail-archive;

  repos = {
    guix-devel = {
      description = "Guix development channel";
      address = [ "guix-devel@gnu.org" ];
      newsgroup = "inbox.comp.guix.devel";
    };

    systemd-devel = {
      address = [ "systemd-devel@lists.freedesktop.org" ];
      description = "systemd development channel";
      newsgroup = "inbox.comp.systemd.devel";
    };
  };
in {
  options.hosts.ni.services.mail-archive.enable =
    lib.mkEnableOption "preferred mail archiving service";

  config = lib.mkIf cfg.enable {
    state.ports.public-inbox-httpd.value = 23456;

    services.public-inbox = {
      enable = true;
      http = {
        enable = true;
        port = "/run/public-inbox-http.sock";
        mounts = [ "https://mail.ni.internal/inbox" ];
      };
      imap.enable = true;
      nntp.enable = true;

      path = with pkgs; [ spamassassin ];

      inboxes = lib.mapAttrs (n: v: {
        inherit (v) description address newsgroup;
        url = "http://mail.ni.internal/inbox/${n}";
        coderepo = [ n ];
      }) repos;

      settings.coderepo = lib.mapAttrs (n: v: {
        dir = "/var/lib/gitea/";
        cgitUrl = "http://git.ni.internal/${n}.git";
      }) repos;
    };

    services.nginx.virtualHosts."mail.ni.internal" = {
      locations."/".return = "302 /inbox";
      locations."= /inbox".return = "302 /inbox/";
      locations."/inbox".proxyPass =
        "http://unix:${config.services.public-inbox.http.port}:/inbox";
      locations."= /style/light.css".alias = pkgs.writeText "light.css" ''
        * { background:#fff; color:#000 }

        a { color:#00f; text-decoration:none }
        a:visited { color:#808 }

        *.q { color:#008 }

        *.add { color:#060 }
        *.del {color:#900 }
        *.head { color:#000 }
        *.hunk { color:#960 }

        .hl.num { color:#f30 } /* number */
        .hl.esc { color:#f0f } /* escape character */
        .hl.str { color:#f30 } /* string */
        .hl.ppc { color:#c3c } /* preprocessor */
        .hl.pps { color:#f30 } /* preprocessor string */
        .hl.slc { color:#099 } /* single-line comment */
        .hl.com { color:#099 } /* multi-line comment */
        /* .hl.opt { color:#ccc } */ /* operator */
        /* .hl.ipl { color:#ccc } */ /* interpolation */

        /* keyword groups kw[a-z] */
        .hl.kwa { color:#f90 }
        .hl.kwb { color:#060 }
        .hl.kwc { color:#f90 }
        /* .hl.kwd { color:#ccc } */
      '';
    };
  };
}
