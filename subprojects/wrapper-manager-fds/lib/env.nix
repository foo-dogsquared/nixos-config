rec {
  /* Given the attrset for evaluating a wrapper-manager module, return a
     derivation containing the wrapper.
  */
  build = args:
    (eval args).config.build.toplevel;

  /* Evaluate a wrapper-manager configuration. */
  eval = {
    pkgs,
    lib ? pkgs.lib,
    modules ? [ ],
    specialArgs ? { },
  }:
    lib.evalModules {
      inherit specialArgs;
      modules = [
        ../modules/wrapper-manager

        # Setting pkgs modularly. This would make setting up wrapper-manager
        # with different nixpkgs instances possible but it isn't something that
        # is explicitly supported.
        ({ lib, ... }: {
          config._module.args.pkgs = lib.mkDefault pkgs;
        })
      ] ++ modules;
    };
}
