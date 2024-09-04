{ pkgs ? import <nixpkgs> { overlays = [ (import ../overlays).default ]; } }:

let
  inherit (pkgs) lib nixosOptionsDoc;

  mkOptionsDoc = args@{ class, modules, includeModuleSystemArguments ? false, ... }:
    let
      modulesEval =
        if class == "nixos"
          then lib.evalModules {
            modules = modules ++ lib.singleton {
              imports = [
                "${pkgs.path}/nixos/modules/misc/extra-arguments.nix"

                # One of the modules requires this to be included.
                "${pkgs.path}/nixos/modules/config/xdg/mime.nix"
              ];
              _module.check = false;
              _module.args.pkgs = pkgs;
              fileSystems."/".device = "nodev";
            };
          }
        else if class == "homeManager"
          then
          let
            hmLib = import <home-manager/lib/stdlib-extended.nix> lib;
          in
          lib.evalModules {
            modules = modules ++ lib.singleton {
              _module.check = false;
              _module.args.pkgs = pkgs;
              lib = hmLib.hm;
            };
          }
        else if class == "wrapperManager" then
          let
            wrapper-manager = import ../subprojects/wrapper-manager-fds { };
          in
          wrapper-manager.lib.eval {
            inherit pkgs;
            modules = modules ++ lib.singleton {
              _module.check = false;
            };
          }
        else
          lib.evalModules {
            modules = modules ++ lib.singleton {
              _module.check = false;
              _module.args.pkgs = pkgs;
            };
          };

      inherit (modulesEval) options;
  in
    nixosOptionsDoc ({
      options =
        if includeModuleSystemArguments
        then options
        else builtins.removeAttrs options [ "_module" ];
      }
      // builtins.removeAttrs args [ "modules" "class" "includeModuleSystemArguments" ]);

  mkManpage = { optionsJSON, asciidocHeader }:
      pkgs.runCommand "wrapper-manager-reference-manpage"
        {
          nativeBuildInputs = with pkgs; [
            nixos-render-docs
            asciidoctor
          ];
        }
        ''
          mkdir -p $out/share/man/man5
          asciidoctor --attribute is-wider-scoped --backend manpage \
            ${asciidocHeader} --out-file header.5
          nixos-render-docs options manpage --revision ${pkgs.lib.version} \
            --header ./header.5 --footer ${./manpages/footer.5} \
            ${optionsJSON}/share/doc/nixos/options.json \
            $out/share/man/man5/wrapper-manager.nix.5
        '';
in
{
  nixos = rec {
    optionsDoc = mkOptionsDoc {
      modules = [ ../modules/nixos ../modules/nixos/_private ];
      class = "nixos";
    };

    outputs.manpage = mkManpage {
      inherit (optionsDoc) optionsJSON;
      asciidocHeader = ./manpages/nixos-header.adoc;
    };
  };

  home-manager = rec {
    optionsDoc = mkOptionsDoc {
      modules = [ ../modules/home-manager ../modules/home-manager/_private ];
      class = "homeManager";
    };

    outputs.manpage = mkManpage {
      inherit (optionsDoc) optionsJSON;
      asciidocHeader = ./manpages/home-manager-header.adoc;
    };
  };

  nixvim = rec {
    optionsDoc = mkOptionsDoc {
      modules = [ ../modules/nixvim ../modules/nixvim/_private ];
      class = "nixvim";
    };

    outputs.manpage = mkManpage {
      inherit (optionsDoc) optionsJSON;
      asciidocHeader = ./manpages/nixvim-header.adoc;
    };
  };

  wrapper-manager = rec {
    optionsDoc = mkOptionsDoc {
      modules = [ ../modules/wrapper-manager ../modules/wrapper-manager/_private ];
      class = "wrapperManager";
    };

    outputs.manpage = mkManpage {
      inherit (optionsDoc) optionsJSON;
      asciidocHeader = ./manpages/wrapper-manager-header.adoc;
    };
  };

  flake-parts = rec {
    optionsDoc = mkOptionsDoc {
      modules = [ ../modules/flake-parts ];
      class = "flakeParts";
    };

    outputs.manpage = mkManpage {
      inherit (optionsDoc) optionsJSON;
      asciidocHeader = ./manpages/flake-parts-header.adoc;
    };
  };

  website = pkgs.callPackage ./website/package.nix { };
}
