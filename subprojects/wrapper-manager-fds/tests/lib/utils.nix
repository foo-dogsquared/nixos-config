{ pkgs, lib, self }:

lib.runTests {
  testsUtilsGetBin = {
    expr = self.utils.getBin [
      ../modules
      ../../modules
    ];
    expected = [
      (lib.getBin ../modules)
      (lib.getBin ../../modules)
    ];
  };

  testsUtilsGetLibexec = {
    expr = self.utils.getLibexec [
      ../modules
      ../../modules
    ];
    expected = [
      "${../modules}/libexec"
      "${../../modules}/libexec"
    ];
  };
}
