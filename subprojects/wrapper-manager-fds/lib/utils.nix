{ pkgs, lib, self }:

rec {
  /*
    Given a list of derivations, return a list of the store path with the `bin`
    output (or at least with "/bin" in each of the paths).
  */
  getBin = drvs:
    builtins.map (v: lib.getBin v) drvs;

  /*
    Given a list of derivations, return a list of the store paths with the
    `libexec` appended.
  */
  getLibexec = drvs:
    builtins.map (v: "${v}/libexec") drvs;

  /*
    Given a list of derivations, return a list of the store paths appended with
    `/etc/xdg` suitable as part of the XDG_CONFIG_DIRS environment variable.
  */
  getXdgConfigDirs = drvs:
    builtins.map (v: "${v}/etc/xdg") drvs;

  /*
    Given a list of derivations, return a list of store paths appended with
    `/share` suitable as part of the XDG_DATA_DIRS environment variable.
  */
  getXdgDataDirs = drvs:
    builtins.map (v: "${v}/share") drvs;
}
