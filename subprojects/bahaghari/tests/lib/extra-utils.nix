# A bunch of utilities to be used in a bunch of tests.
{ lib, self }:

{
  # The typical rounding procedure for our results. 10 decimal places should be
  # enough to test accuracy at least for a basic math subset like this.
  round' = self.math.round' (-10);
}
