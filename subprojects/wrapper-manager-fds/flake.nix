# As a design restriction, this flake shouldn't have any inputs whatsoever.
# We're already using the Nix projects through pinning with npins.
{
  description = "wrapper-manager-fds flake";
  outputs =
    { ... }:
    let
      sources = import ./npins;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      eachSystem =
        systems: f:
        let
          # Merge together the outputs for all systems.
          op =
            attrs: system:
            let
              ret = f system;
              op =
                attrs: key:
                attrs
                // {
                  ${key} = (attrs.${key} or { }) // {
                    ${system} = ret.${key};
                  };
                };
            in
            builtins.foldl' op attrs (builtins.attrNames ret);
        in
        builtins.foldl' op { } (
          systems
          # add the current system if --impure is used
          ++ (
            if builtins ? currentSystem then
              if builtins.elem builtins.currentSystem systems then [ ] else [ builtins.currentSystem ]
            else
              [ ]
          )
        );
    in
    import ./. { }
    // (eachSystem systems (
      system:
      let
        pkgs = import sources.nixos-unstable { inherit system; };
        tests = import ./tests { inherit pkgs; };
        docs = import ./docs { inherit pkgs; };
      in
      {
        devShells = {
          default = import ./shell.nix { inherit pkgs; };
          website = import ./docs/website/shell.nix { inherit pkgs; };
        };

        packages = {
          manpage-reference = docs.outputs.manpage;
          html-reference = docs.outputs.html;
          website = docs.website;
        };

        checks.wrapperManagerLibrarySetPkg = tests.libTestPkg;
      }
    ));
}
