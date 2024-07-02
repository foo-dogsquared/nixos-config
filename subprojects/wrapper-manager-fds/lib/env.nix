{ pkgs, lib, self }:

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
      modules = [ ../modules/wrapper-manager ] ++ modules;
      specialArgs = specialArgs // {
        inherit pkgs;
        modulesPath = builtins.toString ../modules/wrapper-manager;
      };
    };
}
