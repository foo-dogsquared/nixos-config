{ lib, stdenvNoCC, dconf }:

lib.extendMkDerivation {
  constructDrv = stdenvNoCC.mkDerivation;
  excludeDrvArgNames = [
    "enableLocalUserProfile"
    "enableSystemUserProfile"
  ];
  extendDrvArgs =
    finalAttrs:
    {
      # Name of the dconf profile and the database directory.
      name,

      # A list of configuration database for dconf to look into as formatted
      # from {manpage}`dconf(7)`. The given list is assumed to be sorted.
      profile ? [ ],

      # A list of paths containing dconf keyfiles to be placed in
      # `$out/etc/dconf/db/$NAME.d`.
      keyfiles ? [ ],

      # Convenience for adding `user-db:user` as first item of the profile if
      # the given profile list don't have it as the first item.
      enableLocalUserProfile ? false,

      # Convenience for adding `system-db:$NAME` as the second item of the
      # profile if the given profile list don't have it as the second item.
      enableSystemUserProfile ? false,

      ...
    }
    @args:
    let
      profile' =
        lib.optionals (enableLocalUserProfile && !((lib.elemAt profile 0) == "user-db")) [ "user-db:user" ]
        ++ lib.optionals (enableSystemUserProfile && !((lib.elemAt profile 1) == "system-db:${name}")) [ "system-db:${name}" ]
        ++ profile;
    in
    {
      inherit keyfiles;
      profile = lib.concatStringsSep "\n" profile';
      passAsFile = args.passAsFile or [ ] ++ [ "profile" "keyfiles" ];

      buildInputs = args.buildInputs or [ ] ++ [ dconf ];

      buildCommand = ''
        install -Dm0644 "$profilePath" "$out/etc/dconf/profile/${lib.escapeShellArg name}"

        mkdir -p "$out/etc/dconf/db/${lib.escapeShellArg name}.d" && {
          for p in $keyfilesPath; do
            cp -r $p/* "$out/etc/dconf/db/${lib.escapeShellArg name}.d"
          done
        }
      '';

      passthru = args.passthru or { } // {
        dconf = {
          inherit keyfiles;
          profile = profile';
        };
      };
    };
}
