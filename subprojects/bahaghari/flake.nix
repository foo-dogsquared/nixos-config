# For now, it has
{
  description = "Specialized set of Nix modules for generating and applying themes.";

  outputs = { ... }:
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
    in eachSystem systems
      (system: let
        tests = branch: import ./tests { inherit branch system; };
      in {
        devShells.default =
          import ./shell.nix { pkgs = import sources.nixos-stable { inherit system; }; };

        checks = {
          bahaghariLibStable = (tests "stable").libTestPkg;
          bahaghariLibUnstable = (tests "unstable").libTestPkg;
        };
      }) // import ./default.nix { };
}
