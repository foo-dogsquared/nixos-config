{ pkgs, lib, self }:

rec {
  /* Given a Blender package and its addons to be wrapped, create a derivation
     containing all of the addons properly placed as a system resource folder.
  */
  wrapBlenderAddons = { blenderPackage, addons }:
    let
      blenderVersion = lib.versions.majorMinor blenderPackage.version;
    in
    pkgs.runCommand "blender-system-resources"
      {
        passAsFile = [ "paths" ];
        paths = addons ++ [ blenderPackage ];
        nativeBuildInputs = with pkgs; [ outils ];
      } ''
      mkdir -p $out
      for i in $(cat $pathsPath); do
        resourcesPath="$i/share/blender"
        if [ -d $i/share/blender/${blenderVersion} ]; then
          resourcesPath="$i/share/blender/${blenderVersion}";
        fi
        lndir -silent $resourcesPath $out
      done
    '';

  makeBlenderWrapper = module@{ blenderPackage, blenderArgs ? [ ] , addons ? [ ], ... }:
    let
      blenderAddons = wrapBlenderAddons { inherit blenderPackage addons; };
    in
    lib.mkMerge [
      {
        arg0 = lib.getExe' blenderPackage "blender";
        prependArgs = lib.mkBefore blenderArgs;
      }

      (lib.mkIf (builtins.length addons > 0) {
        env.BLENDER_SYSTEM_RESOURCES.value = blenderAddons;
      })

      (lib.removeAttrs module [ "blenderPackage" "blenderArgs" "addons" ])
    ];

  /* Create a configuration module for quickly wrapping with Boxxy.
  */
  makeBoxxyWrapper = module@{ boxxyArgs, wraparound, wraparoundArgs ? [], ... }:
    lib.mkMerge [
      {
        arg0 = lib.getExe' pkgs.boxxy "boxxy";
        prependArgs = lib.mkBefore (boxxyArgs ++ [ "--" wraparound ] ++ wraparoundArgs);
      }

      (builtins.removeAttrs module [ "boxxyArgs" "wraparound" "wraparoundArgs" ])
    ];

  /* Given the path to the source code, the attribute path, and the executable
     name, return the store path to one of its executables.
  */
  getNixglExecutable = { src, variant ? [ "auto" "nixGLDefault" ], nixglProgram ? "nixGL" }:
    let
      nixgl = import src { inherit pkgs; };
      nixglPkg = lib.getAttrFromPath variant nixgl;
    in
      lib.getExe' nixglPkg nixglProgram;

  /* Create a configuration module for quickly wrapping with NixGL.
  */
  makeNixglWrapper = {
    nixglSrc,
    nixglArgs,
    nixglVariant,
    nixglExecutable,
    wraparound,
    wraparoundArgs ? [],
    ...
  }@module:
    lib.mkMerge [
      {
        arg0 = getNixglExecutable nixglSrc nixglVariant nixglExecutable;
        prependArgs = lib.mkBefore (nixglArgs ++ [ "--" wraparound ] ++ wraparoundArgs);
      }

      (builtins.removeAttrs module [
        "nixglArgs" "nixglVariant" "nixglExecutable"
        "wraparound" "wraparoundArgs"
      ])
    ];
}
