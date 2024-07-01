{ pkgs, lib, self }:

lib.runTests {
  testsBuildSampleConfiguration = {
    expr =
      let
        sampleConf = self.env.build {
          inherit pkgs;
          modules = [ ./wrapper-neofetch.nix ];
          specialArgs.yourMomName = "Joe Mama";
        };
      in
        lib.isDerivation sampleConf.config.build.toplevel;
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
        lib.isDerivation sampleConf.config.build.toplevel;
    expected = true;
  };
}
