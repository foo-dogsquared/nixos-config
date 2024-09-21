{ pkgs, lib, self }:

{
  fetchInternetArchive = pkgs.callPackage ./fetch-internet-archive { };
}
