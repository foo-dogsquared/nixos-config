{ lib, writeTextDir, buildEnv, extendedStdenv, direnv, coreutils }:

{ paths ? [ ], pathsToLink ? [ ], ... }@args:

let
  bashProfile = writeTextDir "/etc/bashrc" ''
    # This should only be applied to interactive shells.
    [[ $- == *i* ]] || return

    if [[ -n "$PS1" ]]; then
      shopt -s checkwinsize
      set +h

      PS1="\h $ "

      eval "$(${lib.getExe' direnv "direnv"} hook bash)"
      eval "$(${lib.getExe' coreutils "dircolors"} --sh)"
    fi
  '';
in buildEnv (args // {
  paths = extendedStdenv ++ paths ++ [ bashProfile ];
  pathsToLink = [ "/bin" "/etc" "/share" "/lib" "/libexec" ] ++ pathsToLink;
})
