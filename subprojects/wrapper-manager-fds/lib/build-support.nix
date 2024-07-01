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
    isBinary ? true,

    makeWrapperArgs ? [ ],
    nativeBuildInputs ? [ ],
    passthru ? { },
  }@args:
    pkgs.runCommand "wrapper-manager-script-${executableName}" (
      (builtins.removeAttrs args [ "executableName" "arg0" "isBinary" ])
      // {
        inherit makeWrapperArgs;
        nativeBuildInputs = nativeBuildInputs ++
          (if isBinary then [ pkgs.makeBinaryWrapper ] else [ pkgs.makeWrapper ]);

        passthru = passthru // {
          wrapperScript = { inherit arg0 executableName; };
        };
      }
    ) ''
      mkdir -p $out/bin
      makeWrapper "${arg0}" "$out/bin/${executableName}" ''${makeWrapperArgs[@]}
    '';

  /* Similar to `mkWrapper` but include the output of the given package. */
  mkWrappedPackage = {
    package,
    executableName ? package.meta.mainProgram or package.pname,
    extraPackages ? [ ],
    isBinary ? true,

    postBuild ? "",
    nativeBuildInputs ? [ ],
    makeWrapperArgs ? [ ],
    passthru ? { },
  }@args:
    pkgs.symlinkJoin (
      (builtins.removeAttrs args [ "package" "executableName" "extraPackages" "isBinary" ])
      // {
        name = "wrapper-manager-wrapped-package-${package.pname}";
        paths = [ package ] ++ extraPackages;

        inherit makeWrapperArgs;
        nativeBuildInputs = nativeBuildInputs ++
          (if isBinary then [ pkgs.makeBinaryWrapper ] else [ pkgs.makeWrapper ]);
        passthru = passthru // {
          wrapperScript = { inherit executableName package; };
        };
        postBuild = ''
          ${postBuild}
          wrapProgram "$out/bin/${executableName}" ''${makeWrapperArgs[@]}
        '';
      });
}
