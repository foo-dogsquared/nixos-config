{ pkgs, lib, self }:

let
  neofetchWrapper = ../../configs/wrapper-neofetch.nix;
  fastfetchWrapper = ../../configs/wrapper-fastfetch.nix;
in
lib.runTests {
  testsEvaluateSampleConfiguration = {
    expr =
      let
        sampleConf = self.env.eval {
          inherit pkgs;
          modules = [ neofetchWrapper ];
          specialArgs.yourMomName = "Joe Mama";
        };
      in
        lib.isDerivation sampleConf.config.build.toplevel;
    expected = true;
  };

  testsEvaluateSampleConfiguration2 = {
    expr =
      let
        sampleConf = self.env.eval {
          inherit pkgs;
          modules = [ fastfetchWrapper ];
          specialArgs.yourMomName = "Joe Mama";
        };
      in
        lib.isDerivation sampleConf.config.build.toplevel;
    expected = true;
  };

  testsBuildSampleConfiguration = {
    expr =
      let
        sampleConf = self.env.build {
          inherit pkgs;
          modules = [ neofetchWrapper ];
          specialArgs.yourMomName = "Joe Mama";
        };
      in
        lib.isDerivation sampleConf;
    expected = true;
  };

  testsBuildSampleConfiguration2 = {
    expr =
      let
        sampleConf = self.env.build {
          inherit pkgs;
          modules = [ fastfetchWrapper ];
          specialArgs.yourMomName = "Joe Mama";
        };
      in
        lib.isDerivation sampleConf;
    expected = true;
  };
}
