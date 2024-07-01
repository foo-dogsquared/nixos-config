{ pkgs, lib, self }:

rec {
  /*
    Given a list of derivations, return a list of the store path with the `bin`
    output (or at least with "/bin" in each of the paths).
  */
  getBin = drvs:
    builtins.map (v: lib.getBin v) drvs;

  /*
  */
  getLibexec = drvs:
    builtins.map (v: "${v}/libexec") drvs;
}
