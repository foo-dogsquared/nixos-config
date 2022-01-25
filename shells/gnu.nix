# The GNU build system. Commonly used for projects at GNU and anyone who wants
# to be a GNU fanatic.
#
# It's a good thing they have documented the full details in one of their
# manuals at
# https://www.gnu.org/software/automake/manual/html_node/GNU-Build-System.html
{ mkShell, lib, autoconf, autoconf-archive, automake, gnumake, gcc, gettext, coreutils, pkg-config }:

mkShell {
  packages = [
    autoconf
    autoconf-archive
    automake
    coreutils
    gettext
    gcc
    pkg-config
  ];
}
