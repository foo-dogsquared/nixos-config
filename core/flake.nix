# This is mainly for "public" consumption of the modules and several components
# found in my project which shouldn't really require no flake inputs
# whatsoever.
{
  description = "foodogsquared's core flake for its modules";

  outputs = { ... }: import ./. { };
}
