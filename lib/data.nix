# Anything that has to do with interacting with data especially with external
# ones (that is, anything that is not represented as a Nix object).
# Unfortunately, most of these functions are surely going to use packages found
# in nixpkgs so expect a lot of them are used as an IFD.
{ pkgs, lib, self }:

{
  /**
    Import the YAML file and return it as a Nix object. Unfortunately, this is
    implemented as an import-from-derivation (IFD) so it will not be pretty.

    # Arguments

    path
    : The path of the YAML file.

    # Type

    ```
    importYAML :: Path -> Attrs
    ```

    # Examples

    ```nix
    importYAML ./your-mom.yaml
    => { name = "Yor Mum"; age = 56; world = "Herown"; }
    ```
  */
  importYAML = path:
    let
      dataDrv = pkgs.runCommand "convert-yaml-to-json" { } ''
        ${lib.getExe' pkgs.yaml2json "yaml2json"} < "${path}" > "$out"
      '';
    in lib.importJSON dataDrv;

  /**
    Render a Tera template given a parameter set powered by `tera-cli`. Also
    typically used as an IFD.

    # Arguments

    It's a sole attribute set with the following attributes:

    template
    : The template file to be used.

    context
    : An attribute set containing the data used alongside the template.

    extraArgs
    : An attrset of command line arguments (same as
    `lib.cli.toGNUCommandLineShell`) to be added on top of the typical
    arguments used by the function.

    # Type

    ```
    renderTeraTemplate :: Attrs -> Path
    ```

    # Example

    ```nix
    renderTeraTemplate { path = ./template.tera; context = { hello = 34; }; }
    => /nix/store/HASH-tera-render-template
    ```
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

  /**
    Render a Mustache template given a parameter set powered by `mustache-go`.
    Also typically used as an IFD.

    # Arguments

    It's a sole attribute set with the following attributes:

    template
    : The path containing the template file.

    context
    : An attribute set of metadata used in the template file.

    extraArgs
    : An attrset of additional command line arguments (same as the argument
    used in `lib.cli.toGNUCommandLineShell`) on top of the typical arguments
    used in the function.

    # Type

    ```
    renderMustacheTemplate :: Attrs -> Path
    ```

    # Examples

    ```nix
    renderMustacheTemplate { path = ./template.mustache; context = { hello = 34; }; }
    => /nix/store/HASH-mustache-render-template
    ```
  */
  renderMustacheTemplate = { template, context, extraArgs ? { } }:
    let extraArgs' = lib.cli.toGNUCommandLineShell { } extraArgs;
    in pkgs.runCommand "mustache-render-template" {
      nativeBuildInputs = with pkgs; [ mustache-go ];
      context = builtins.toJSON context;
      passAsFile = [ "template" "context" ];
    } ''
      mustache "$contextPath" "${template}" ${extraArgs'} > $out
    '';
}
