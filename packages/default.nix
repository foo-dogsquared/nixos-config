[
  (self: super: with super; {
    # Add packages from the unstable channel with `pkgs.unstable.$PKG`.
    veikk-linux-driver = (callPackage ./veikk-driver.nix { kernel = pkgs.linux_5_8; });
    nur.foo-dogsquared = import (
      fetchTarball "https://github.com/foo-dogsquared/nur-packages/archive/develop.tar.gz"
    ) { inherit pkgs; };
  })
]
