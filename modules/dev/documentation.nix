# My stuff for documentation workflows.
# I mean, documentation is part of the development life, right?
# Mainly includes markup languages and whatnot.
{ config, options, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.dev.documentation;
in {
  options.modules.dev.documentation = let
    mkBoolOption = bool:
      mkOption {
        type = types.bool;
        default = bool;
      };
  in {
    enable = mkBoolOption false;

    # Jupyter does need a bit of setup so separate option.
    jupyter.enable = mkBoolOption false;

    # Since my usual LaTeX needs are somewhat big, I'm keeping it as a separate option.
    latex.enable = mkBoolOption false;
  };

  config = mkIf cfg.enable {
    my.packages = with pkgs;
      [
        asciidoctor # An Asciidoctor document keeps a handful of few frustrated users a day.
        aspell # The not-opinionated spell checker.
        aspellDicts.en
        aspellDicts.en-computers
        #aspellDicts.en-science
        editorconfig-core-c # A library just for formatting files?
        editorconfig-checker # Check yer formatting.
        hugo # An SSG for your DDD (documentation-driven development) workflow.
        languagetool # A grammar checker with a HUGE data set.
        pandoc # The Swiss army knife for document conversion.
        R # Rated G for accessibility.
        vale # The customizable linter for your intended writings.

        # TODO: Make Neuron its own package.
        (let
          neuronRev = "e7568ca5f51609bb406a48527b5ba52d31d11f9c";
          neuronSrc = builtins.fetchTarball
            "https://github.com/srid/neuron/archive/${neuronRev}.tar.gz";
        in import neuronSrc { }) # Neurons and zettels are good for the brain.
      ] ++

      (if cfg.jupyter.enable then [
        jupyter # The interactive notebook.
        iruby # The Ruby kernel for Jupyter.
      ] else
        [ ]) ++

      (if cfg.latex.enable then
        [
          texlive.combined.scheme-medium # The all-in-one LaTeX distribution for your offline typesetting needs.
        ]
      else
        [ ]);
  };
}
