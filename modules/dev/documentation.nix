# My stuff for documentation workflows.
# I mean, documentation is part of the development life, right?
# Mainly includes markup languages and whatnot.
{ config, options, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.dev.documentation;
in
{
  options.modules.dev.documentation = 
    let mkBoolOption = bool: mkOption {
      type = types.bool;
      default = bool;
    }; in {
    enable = mkBoolOption false;

    # Since my usual LaTeX needs are somewhat big, I'm keeping it as a separate option.
    latex.enable = mkBoolOption false;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      asciidoctor       # Keeping Asciidoc alive with the improved version.
      hugo              # An SSG for your DDD (documentation-driven development) workflow.
      pandoc            # The Swiss army knife for document conversion.

      # TODO: Make Neuron its own package.
      (let neuronSrc = builtins.fetchTarball "https://github.com/srid/neuron/archive/master.tar.gz";
        in import neuronSrc {})     # Neurons and zettels are good for the brain.
    ] ++

    (if cfg.latex.enable then [
      texlive.combined.scheme-medium       # The all-in-one LaTeX distribution for your offline typesetting needs.
    ] else []);
  };
}
