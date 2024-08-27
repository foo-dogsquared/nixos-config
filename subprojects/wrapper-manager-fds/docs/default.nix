let
  sources = import ../npins;
in
{
  pkgs ? import sources.nixos-unstable { },
}:

let
  inherit (pkgs) nixosOptionsDoc lib;

  src = builtins.toString ../.;

  # Pretty much inspired from home-manager's documentation build process.
  evalDoc =
    args@{
      modules,
      includeModuleSystemOptions ? false,
      ...
    }:
    let
      options =
        (pkgs.lib.evalModules {
          modules = modules ++ [
            {
              _module.check = false;
              _module.args.pkgs = pkgs;
            }
          ];
          class = "wrapperManager";
        }).options;

    # Based from nixpkgs' and home-manager's code.
    gitHubDeclaration = user: repo: subpath:
      {
        url = "https://github.com/${user}/${repo}/blob/master/${subpath}";
        name = "<${repo}/${subpath}>";
      };

    in
    nixosOptionsDoc (
      {
        options =
          if includeModuleSystemOptions then options else builtins.removeAttrs options [ "_module" ];
        transformOptions = opt:
          opt // {
            declarations = map (decl:
              if lib.hasPrefix src (toString decl) then
                gitHubDeclaration "foo-dogsquared" "wrapper-manager-fds"
                (lib.removePrefix "/" (lib.removePrefix src (toString decl)))
              else if decl == "lib/modules.nix" then
                gitHubDeclaration "NixOS" "nixpkgs" decl
              else
                decl) opt.declarations;
          };
      }
      // builtins.removeAttrs args [
        "modules"
        "includeModuleSystemOptions"
      ]
    );
  releaseConfig = lib.importJSON ../release.json;

  wrapperManagerLib = (import ../. { }).lib;
  wmOptionsDoc = evalDoc {
    modules = [ ../modules/wrapper-manager ];
    includeModuleSystemOptions = true;
  };

  gems = pkgs.bundlerEnv {
    name = "wrapper-manager-fds-gem-env";
    ruby = pkgs.ruby_3_1;
    gemdir = ./.;
  };
in
{
  # I forgot about the fact Hugo also uses Go modules for its Hugo modules
  # feature. For now, this is considered broken up until that is working and I
  # know squat about Go build system. Also, Hugo has several features such as
  # embedding metadata from VCS which doesn't play well with Nix that is
  # requiring a clean source.
  #
  # For now, we're just relying on nix-shell to build it for us.
  website =
    let
      buildHugoSite = pkgs.callPackage ./hugo-build-module.nix { };

      # Now this is some dogfooding.
      asciidoctorWrapped = wrapperManagerLib.build {
        inherit pkgs;
        modules = [
          (
            {
              config,
              lib,
              pkgs,
              ...
            }:
            {
              wrappers.asciidoctor = {
                arg0 = lib.getExe' gems "asciidoctor";
                appendArgs = [
                  "-T"
                  "${sources.website}/templates"
                ];
              };
            }
          )
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
  wmNixosDoc = evalDoc { modules = [ ../modules/env/nixos ]; };
  wmHmDoc = evalDoc { modules = [ ../modules/env/home-manager ]; };

  inherit releaseConfig;
  outputs = {
    manpage =
      pkgs.runCommand "wrapper-manager-reference-manpage"
        {
          nativeBuildInputs = with pkgs; [
            nixos-render-docs
            gems
            gems.wrappedRuby
          ];
        }
        ''
          mkdir -p $out/share/man/man5
          asciidoctor --backend manpage ${./manpages/header.adoc} --out-file header.5
          nixos-render-docs options manpage --revision ${releaseConfig.version} \
            --header ./header.5 --footer ${./manpages/footer.5} \
            ${wmOptionsDoc.optionsJSON}/share/doc/nixos/options.json \
            $out/share/man/man5/wrapper-manager.nix.5
        '';

    html =
      pkgs.runCommand "wrapper-manager-reference-html"
        {
          nativeBuildInputs = [
            gems
            gems.wrappedRuby
          ];
        }
        ''
          mkdir -p $out/share/wrapper-manager
          asciidoctor --backend html ${wmOptionsDoc.optionsAsciiDoc} --attribute toc --out-file $out/share/wrapper-manager/options-reference.html
        '';
  };
}
