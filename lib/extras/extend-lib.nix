# A lambda suitable to be used for `pkgs.lib.extend`.
self: super: let
  publicLib = import ../. { lib = super; };
in
{
  inherit (publicLib) filesToAttr countAttrs getSecrets
    attachSopsPathPrefix;

  # Until I figure out how to properly add them only for their respective
  # environment, this is the working solution for now. Not really perfect
  # since we use one nixpkgs instance for each configuration (home-manager or
  # otherwise).
  private = publicLib
            // import ../private.nix { lib = self; }
            // import ../home-manager.nix { lib = self; };
}
