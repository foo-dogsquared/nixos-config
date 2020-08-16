[
  (self: super: with super; {
    # defold = (callPackage ./defold.nix {});
  })

  (import (builtins.fetchTarball https://github.com/nix-community/emacs-overlay/archive/master.tar.gz))
]
