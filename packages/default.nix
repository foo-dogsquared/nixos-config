[
  (self: super: with super; {

    # Add packages from the unstable channel with `pkgs.unstable.$PKG`.
    unstable = import <nixpkgs-unstable> { inherit config; };
    nur.foo-dogsquared = import (
      fetchTarball "https://github.com/foo-dogsquared/nur-packages/archive/develop.tar.gz"
    ) { inherit pkgs; };
  })

  # The unstable branch of Emacs.
  # (import (builtins.fetchTarball https://github.com/nix-community/emacs-overlay/archive/master.tar.gz))
]
