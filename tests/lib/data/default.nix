{ pkgs, lib, self }:

lib.runTests {
  testImportYAML = {
    expr = self.data.importYAML ./data/sample.yaml;
    expected = {
      hello = "world";
      whoa = 4566;
      list-of-names = [
        "Cheesy" "Angry" "Ash"
      ];
    };
  };

  testImportYAMLAsJSON = {
    expr = self.data.importYAML ./data/sample.json;
    expected = {
      hello = "world";
      whoa = 4566;
      list-of-names = [
        "Cheesy" "Angry" "Ash"
      ];
    };
  };

  testRenderTeraTemplate = {
    expr = builtins.readFile (self.data.renderTeraTemplate {
      template = ./templates/sample.tera;
      context = lib.importJSON ./data/sample.json;
    });
    expected = builtins.readFile ./fixtures/sample.tera;
  };

  testRenderMustacheTemplate = {
    expr = builtins.readFile (self.data.renderTeraTemplate {
      template = ./templates/sample.mustache;
      context = lib.importJSON ./data/sample.json;
    });
    # There the same lol.
    expected = builtins.readFile ./fixtures/sample.tera;
  };
}
