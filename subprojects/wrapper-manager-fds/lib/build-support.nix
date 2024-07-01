# Unless you're a third-party module author wanting to integrate
# wrapper-manager to whatever bespoke configuration environment, there is
# almost no reason to use the following functions, really.
{ pkgs, lib, self }:

{
  /* The build function for making simple and single executable
     wrappers similar to nixpkgs builders for various ecosystems (for example,
     `buildGoPackage` and `buildRustPackage`). 
  */
  mkWrapper = {
    arg0,
    executableName ? arg0,
    makeWrapperArgs ? [ ],

    nativeBuildInputs ? [ ],
    passthru ? { },
  }@args:
    pkgs.runCommand "wrapper-manager-script-${arg0}" (
      (builtins.removeAttrs args [ "executableName" "arg0" ])
      // {
        inherit makeWrapperArgs;
        nativeBuildInputs = nativeBuildInputs ++ [ pkgs.makeWrapper ];

        passthru = passthru // {
          wrapperScript = { inherit arg0 executableName; };
        };
      }
    ) ''
      mkdir -p $out/bin
      makeWrapper ${arg0} "$out/bin/${executableName}" ''${makeWrapperArgs[@]}
    '';

  mkWrappedPackage = {
    package,
    executableName ? package.meta.mainProgram or package.pname,

    postBuild ? "",
    nativeBuildInputs ? [ ],
    makeWrapperArgs ? [ ],
    passthru ? { },
  }@args:
    pkgs.symlinkJoin (
      (builtins.removeAttrs args [ "package" "executableName" ])
      // {
        name = "wrapper-manager-wrapped-package-${package.pname}";
        paths = [ package ];

        inherit makeWrapperArgs;
        nativeBuildInputs = nativeBuildInputs ++ [ pkgs.makeWrapper ];
        passthru = passthru // {
          wrapperScript = { inherit executableName package; };
        };
        postBuild = ''
          ${postBuild}
          wrapProgram "${lib.getExe' package executableName}" ''${makeWrapperArgs[@]}
        '';
      });

}
