{ pkgs, lib, self }:

lib.runTests {
  testsEvaluateSampleConfiguration = {
    expr =
      let
        sampleConf = self.env.eval {
          inherit pkgs;
          modules = [ ./wrapper-neofetch.nix ];
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
          modules = [ ./wrapper-fastfetch.nix ];
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
          modules = [ ./wrapper-neofetch.nix ];
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
          modules = [ ./wrapper-fastfetch.nix ];
          specialArgs.yourMomName = "Joe Mama";
        };
      in
        lib.isDerivation sampleConf;
    expected = true;
  };
}
