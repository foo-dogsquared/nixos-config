{ lib, stdenvNoCC }:

lib.extendMkDerivation {
  constructDrv = stdenvNoCC.mkDerivation;
  excludeDrvArgNames = [
    "lockAll"
  ];
  extendDrvArgs =
    finalAttrs:
    {
      # The filename of the dconf lock and the keyfile.
      name,

      # The attribute containing the actual DConf settings.
      settings ? { },

      # List of keys to be locked and generated at
      # `$out/locks/fds-nix-generated`.
      locks ? [ ],

      # Generate a dconf keylocks for all of the given settings.
      lockAll ? false,

      ...
    }
    @args:
    let
      mkLocks = s:
        # It has to be done this way since it is typically passed as an attrset
        # of attrset with atomic values.
        lib.flatten (lib.mapAttrsToList (k: v: lib.mapAttrsToList (k': _: "/${k}/${k'}") v) s);

      locks' =
        if lockAll then mkLocks settings else locks;

      name' = lib.escapeShellArg name;
    in
    {
      passAsFile = args.passAsFile or [ ] ++ [ "settings" "locks" ];
      settings = lib.generators.toDconfINI settings;
      locks = lib.concatStringsSep "\n" locks';

      allowSubstitutes = args.allowSubstitutes or false;
      preferLocalBuild = args.preferLocalBuild or true;

      buildCommand = ''
        mkdir -p $out && cp "$settingsFile" "$out/${name'}"

        ${lib.optionalString ((lib.length locks') > 0) ''
          install -Dm0644 "$locksPath" "$out/locks/${name'}"
        ''}
      '';
    };
}
