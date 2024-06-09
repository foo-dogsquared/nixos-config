# Anything that has to do with interacting with data especially with external
# ones (that is, anything that is not represented as a Nix object).
# Unfortunately, most of these functions are surely going to use packages found
# in nixpkgs so expect a lot of them are used as an IFD.
{ pkgs, lib, self }:

{
  /* Import the YAML file and return it as a Nix object. Unfortunately, this is
     implemented as an import-from-derivation (IFD) so it will not be pretty.

     Type: importYAML :: Path -> Attrs

     Example:
       importYAML ./your-mom.yaml
       => { name = "Yor Mum"; age = 56; world = "Herown"; }
  */
  importYAML = path:
    let
      dataDrv = pkgs.runCommand "convert-yaml-to-json" { } ''
        ${lib.getExe' pkgs.yaml2json "yaml2json"} < "${path}" > "$out"
      '';
    in lib.importJSON dataDrv;

  /* Render a Tera template given a parameter set powered by `tera-cli`. Also
     typically used as an IFD.

     Type: renderTeraTemplate :: Attrs -> Path

     Example:
       renderTeraTemplate { path = ./template.tera; context = { hello = 34; }; }
       => /nix/store/HASH-tera-render-template
  */
  renderTeraTemplate = { template, context, extraArgs ? { } }:
    let
      extraArgs' = lib.cli.toGNUCommandLineShell { } extraArgs;

      # Take note we're generating the context file in this way since tera-cli
      # can only detect them through its file extension and doesn't have a way
      # of explicitly reading files as JSON, YAML, etc.
      settingsFormat = pkgs.formats.json { };
      contextFile = settingsFormat.generate "tera-context.json" context;
    in pkgs.runCommand "tera-render-template" {
      nativeBuildInputs = with pkgs; [ tera-cli ];
    } ''
      tera --out "$out" ${extraArgs'} --template "${template}" "${contextFile}"
    '';
}
