[
  (self: super: with super; {
    nur-foo-dogsquared = import (
      fetchTarball "https://github.com/foo-dogsquared/nix-expressions/archive/master.tar.gz") { };
    );
  );

    # Add packages from the unstable channel with `pkgs.unstable.$PKG`.
    unstable = import <nixpkgs-unstable> { inherit config; };
  })

  # The unstable branch of Emacs.
  # (import (builtins.fetchTarball https://github.com/nix-community/emacs-overlay/archive/master.tar.gz))
]
