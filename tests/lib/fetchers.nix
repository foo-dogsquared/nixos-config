{
  pkgs ? import <nixpkgs> { },
  lib ? pkgs.lib,
  self ? import ../../lib { inherit pkgs; },
}:

{
  testsInternetArchiveFetcher =
    self.fetchers.fetchInternetArchive {
      id = "md_music_sonic_the_hedgehog";
      file = "01 - Title Theme - Masato Nakamura.flac";
      hash = "sha256-kGjsVjtjXK9imqyi4GF6qkFVmobiTAe/ZAeEwiouqS4=";
    };

  testsInternetArchiveFetcher2 =
    self.fetchers.fetchInternetArchive {
      id = "md_music_sonic_the_hedgehog";
      formats = [ "TEXT" "PNG" ];
      hash = "sha256-xbhasJ/wEgcY+EcBAJp5UoYB4N4It3QV/iIeGGdCET8=";
    };
}
