{ config, options, lib, pkgs, bahaghariLib, ... }:

{
  options.bahaghari.panapton = {
    package = lib.mkPackageOption pkgs "panapton" { };

    dataFiles = lib.mkOption {
      type = with lib.types; listOf package;
      default = [ ];
      description = ''
        A list of derivations containing Panapton data files (e.g., templates,
        schemes) to be included within Panapton builder operations. It is
        expected that the data files are in `$out/share/panapton`.

        If you want to include only a specific type of data file, you can use
        {option}`bahaghari.panapton.{scheme,template}Dirs` instead.
      '';
      example = ''
        [
          (pkgs.callPackage ./custom-panapton-schemes-and-templates.nix)
          pkgs.foodogsquared-panapton-data-files
        ]
      '';
    };

    schemeDirs = lib.mkOption {
      type = with lib.types; listOf path;
      description = ''
        A list of scheme directories to be included within Panapton builder
        operations.
      '';
      default = [ ];
      example = ''
        [
          ./foodogsquared-custom-panapton-schemes
          ./foodogsquared-custom-panapton-schemes-extension
        ]
      '';
    };

    templateDirs = lib.mkOption {
      type = with lib.types; listOf path;
      description = ''
        A list of template directories to be included within Panapton builder
        operations.
      '';
      default = [ ];
      example = ''
        [
          ./my-panapton-templates
          ./my-other-panapton-templates
        ]
      '';
    };
  };

}
