[
  (self: super: with super; {
    # defold = (callPackage ./defold.nix {});

    # Add packages from the unstable channel with `pkgs.unstable.$PKG`.
    unstable = import <nixpkgs-unstable> { inherit config; };
  })

  # The unstable branch of Emacs.
  # (import (builtins.fetchTarball https://github.com/nix-community/emacs-overlay/archive/master.tar.gz))
]
