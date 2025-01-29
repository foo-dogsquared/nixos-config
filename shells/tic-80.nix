# The rest of the tools is your preferences (i.e., image editor, text
# editor). This comes with the development for PRO version to enable
# development with plain text cartridges.
{ mkShell, tic-80, imagemagick }:

mkShell { packages = [ tic-80 tic-80.dev imagemagick ]; }
