{ config, lib, pkgs, ... }:

{
  wrappers.neofetch = {
    arg0 = lib.getExe' pkgs.neofetch "neofetch";
    appendArgs = [
      "--ascii_distro"
      "guix"
      "--title_fqdn"
      "off"
      "--os_arch"
      "off"
    ];
  };

  # Testing out a simple file.
  files."share/nix/hello".text = ''
    WHOA THERE!
  '';

  # A file target with an "absolute" path.
  files."/absolute/path".text = ''
    WHAAAAAAAT!
  '';

  # Testing out source.
  files."share/nix/aloha".source = config.files."share/nix/hello".source;

  # Testing out an executable file.
  files."share/nix/example" = {
    text = "WHOA";
    mode = "0755";
  };

  # Testing out a directory.
  files."share/whoa".source = pkgs.writeTextDir "/what/is/this.txt" ''
    WHAT
  '';

  build.extraPassthru.tests = {
    actuallyBuilt =
      let
        wrapper = config.build.toplevel;
      in
      pkgs.runCommand "wrapper-manager-neofetch-actually-built" { } ''
        [ -x "${wrapper}/bin/${config.wrappers.neofetch.executableName}" ] \
        && [ -f "${wrapper}/share/nix/hello" ] \
        && [ -f "${wrapper}/share/nix/aloha" ] \
        && [ -x "${wrapper}/share/nix/example" ] \
        && [ -d "${wrapper}/share/whoa" ] \
        && [ -f "${wrapper}/absolute/path" ] \
        && touch $out
      '';
  };
}
