[
  (self: super:
    with super; {
      veikk-linux-driver =
        (callPackage ./veikk-driver.nix { kernel = pkgs.linux_5_8; });
      nur.foo-dogsquared = import (fetchTarball
        "https://github.com/foo-dogsquared/nur-packages/archive/master.tar.gz") {
          inherit pkgs;
        };
    })
]
