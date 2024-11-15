{ pkgs, lib, self }:

{
  fetchInternetArchive = pkgs.callPackage ./fetch-internet-archive { };
  fetchUgeeDriver = pkgs.callPackage ./fetch-ugee-driver { };
}
