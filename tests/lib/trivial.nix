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

  testFilterAttrs' = {
    expr = self.trivial.filterAttrs' (n: v: v == 4) {
      e = 5;
      f = 7;
      a = 4;
    };
    expected = {
      ok = { a = 4; };
      notOk = { e = 5; f = 7; };
    };
  };
}
