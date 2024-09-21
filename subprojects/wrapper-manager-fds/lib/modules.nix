# These are functions that are only meant to be invoked inside of a
# wrapper-manager environment.
#
# On a note for wrapper-manager developer(s), due to how tedious it can be to
# test library functions like that, we're putting them inside of the test
# configs instead of the typical library test suite.
{
  pkgs,
  lib,
  self,
}:

rec {
  /*
    Make a wrapper-manager wrapper config containing a sub-wrapper that wraps
    another program. Several examples of this includes sudo, Bubblewrap, and
    Gamescope.
  */
  makeWraparound = {
    arg0,
    under,
    underFlags ? [ ],
    underSeparator ? "",
    ...
  }@module:
    let
      # These are the attrnames that would be overtaken with the function and
      # will be merged anyways so...
      functionArgs = builtins.functionArgs makeWraparound;
      module' = lib.removeAttrs module (lib.attrNames functionArgs);
    in
      lib.mkMerge [
        {
          arg0 = under;

          # This should be the very first things to be in the arguments so
          # we're just making sure that it is the case. The priority is chosen
          # arbitrarily just in case the user already has `prependArgs` values
          # with `lib.mkBefore` for the original arg0.
          prependArgs = lib.mkOrder 250 (
            underFlags
            ++ lib.optionals (underSeparator != "") [ underSeparator ]
            ++ [ arg0 ]
          );
        }

        # It's constructed like this to make it ergonomic to use. The user can
        # simply delete the makeWraparound exclusive arguments and still work
        # normally.
        module'
      ];
}
