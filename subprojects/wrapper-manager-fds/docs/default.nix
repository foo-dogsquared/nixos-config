# I forgot about the fact Hugo also uses Go modules for its Hugo modules
# feature. For now, this is considered broken up until that is working. Also,
# Hugo has several features such as embedding metadata from VCS which doesn't
# play well with Nix that is requiring a clean source.
#
# For now, we're just relying on nix-shell to build it for us.
let
  sources = import ../npins;
in
{ pkgs ? import sources.nixos-unstable { } }:

let
  inherit (pkgs) nixosOptionsDoc stdenv lib;

  # Pretty much inspired from home-manager's documentation build process.
  evalDoc = args@{ modules, includeModuleSystemOptions ? false, ... }:
    let
      options = (pkgs.lib.evalModules {
        modules = modules ++ [ { _module.check = false; _module.args.pkgs = pkgs; } ];
        class = "wrapperManager";
      }).options;
    in
    nixosOptionsDoc ({
      options =
        if includeModuleSystemOptions
        then options
        else builtins.removeAttrs options [ "_module" ];
      }
      // builtins.removeAttrs args [ "modules" "includeModuleSystemOptions" ]);
  buildHugoSite = pkgs.callPackage ./hugo-build-module.nix { };

  wmOptionsDoc = evalDoc {
    modules = [ ../modules/wrapper-manager ];
    includeModuleSystemOptions = true;
  };
in
{
  website =
    let
      gems = pkgs.bundlerEnv {
        name = "wrapper-manager-fds-gem-env";
        ruby = pkgs.ruby_3_1;
        gemdir = ./.;
      };

      wrapperManagerLib = (import ../. { }).lib;

      # Now this is some dogfooding.
      asciidoctorWrapped =
        wrapperManagerLib.build {
          inherit pkgs;
          modules = [
            ({ config, lib, pkgs, ... }: {
              wrappers.asciidoctor = {
                arg0 = lib.getExe' gems "asciidoctor";
                appendArgs = [
                  "-T" "${sources.website}/templates"
                ];
              };
            })
          ];
        };
    in
    buildHugoSite {
      pname = "wrapper-manager-docs";
      version = "2024-07-13";

      src = lib.fileset.toSource {
        root = ./.;
        fileset = lib.fileset.unions [
          ./website/assets
          ./website/config
          ./website/content
          ./website/layouts
          ./website/go.mod
          ./website/go.sum
        ];
      };

      vendorHash = "sha256-vMLi8of2eF/s60B/lM3FDfSntEyieGkvJbTSMuI7Wws=";

      buildInputs = with pkgs; [
        asciidoctorWrapped
        hugo
        git
        gems
        gems.wrappedRuby
      ];

      meta = with lib; {
        description = "wrapper-manager-fds documentation";
        homepage = "https://github.com/foo-dogsquared/wrapper-manager-fds";
        license = with licenses; [
          mit
          fdl13Only
        ];
        platforms = platforms.all;
      };
    };

  inherit wmOptionsDoc;
  wmNixosDoc = evalDoc { modules = [ ../modules/env/nixos ];  };
  wmHmDoc = evalDoc { modules = [ ../modules/env/home-manager ]; };

  manualPage = pkgs.runCommand "wrapper-manager-reference-manpage" {
    nativeBuildInputs = with pkgs; [ nixos-render-docs ];
  } ''
    mkdir -p $out/share/man/man5
    nixos-render-docs options manpage \
      ${wmOptionsDoc.optionsJSON}/share/doc/nixos/options.json \
      $out/share/man/man5/wrapper-manager.nix.5
  '';
}
