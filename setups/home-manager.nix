# This is project data for deploying home-manager users with this flake. Each
# of the users defined here should correspond to one of the home-manager users
# at `./users/home-manager/`.
{ lib, inputs }:

{
  foo-dogsquared.systems = [ "aarch64-linux" "x86_64-linux" ];
  plover.systems = [ "x86_64-linux" ];
}
