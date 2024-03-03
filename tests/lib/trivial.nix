{ pkgs, lib, self }:

lib.runTests {
  testCountAttrs = {
    expr = self.trivial.countAttrs (n: v: v?enable && v.enable) {
      hello.enable = true;
      what.enable = false;
      atro.enable = true;
      adelie = { };
      world = "there";
      mo = null;
    };
    expected = 2;
  };

  testGetConfig = {
    expr = self.trivial.getConfig "home-manager" "foo-dogsquared";
    expected = ../../configs/home-manager/foo-dogsquared;
  };
}
