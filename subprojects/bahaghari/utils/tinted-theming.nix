{ config, lib, pkgs, bahaghariLib }:

let cfg = config.bahaghari.tinted-theming;
in rec {
  # Return a derivation containing all of the template output from the given
  # schemes.
  generateOutputFromSchemes = { schemes ? { }, template }:
    let
      schemesDir = pkgs.runCommand "aggregate-schemes" { } ''
        mkdir -p "$out"
        ${lib.concatMapStrings (scheme: ''
          echo <<EOF > "$out/${scheme.name}.yml"
            ${bahaghariLib.toYAML scheme}
          EOF
        '') lib.attrNames schemes}
      '';
    in pkgs.runCommand "generate-templates" { } (cfg.builder.script {
      inherit schemesDir;
      templateDir = template;
    });

  # Return a derivation containing the generated template with the given
  # builder script with all of the Tinted Theming schemes.
  generateOutputFromAllSchemes = { template }:
    generateOutputFromSchemes {
      schemes = cfg.schemes;
      inherit template;
    };
}
