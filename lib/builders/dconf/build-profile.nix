{ lib, stdenvNoCC }:

lib.extendMkDerivation {
  constructDrv = stdenvNoCC.mkDerivation;
  excludeDrvArgNames = [ "profile" "enableLocalUserProfile" ];
  extendDrvArgs =
    finalAttrs:
    {
      profile ? [ ],

      enableLocalUserProfile ? false,

      ...
    }
    @args:
    let
      profile' =
        lib.optionals (enableLocalUserProfile && !((lib.elemAt profile 0) == "user-db")) [ "user-db:user" ]
        ++ profile;
    in
    {
      profile = lib.concatStringsSep "\n" profile';
      passAsFile = args.passAsFile or [ ] ++ [ "profile" ];
      buildCommand = ''
        install -Dm0644 "$profilePath" $out
      '';

      passthru = args.passthru or { } // {
        profile = profile';
      };
    };
}
