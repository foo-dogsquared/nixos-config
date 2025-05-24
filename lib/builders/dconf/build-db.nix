# A standalone version of the dconf profile generation build step based from
# the nixpkgs' NixOS dconf module.
{ stdenvNoCC, lib, dconf, symlinkJoin }:

lib.extendMkDerivation {
  constructDrv = stdenvNoCC.mkDerivation;
  extendDrvArgs =
    finalAttrs:
    {
      # A list of directories containing the keyfiles to be compiled.
      paths ? [ ],
      ...
    }@args:
    let
      dconfKeyfilePath = symlinkJoin {
        name = "fds-nix-${finalAttrs.pname}-generated-dconf-db";
        inherit paths;
      };
    in
    {
      inherit paths;
      passAsFile = args.passAsFile or [ ] ++ [ "paths" ];

      buildInputs = args.buildInputs or [ ] ++ [ dconf ];
      buildCommand = ''
        dconf compile $out ${dconfKeyfilePath}
      '';

      passthru = args.passthru or { } // {
        dconf.paths = finalAttrs.paths;
      };
    };
}
