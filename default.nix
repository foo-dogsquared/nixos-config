{ compat-flake ? "flake-compat-fds" }:

(import (let lock = builtins.fromJSON (builtins.readFile ./flake.lock);
in fetchTarball {
  url =
    lock.nodes.${compat-flake}.locked.url or "https://github.com/edolstra/flake-compat/archive/${lock.nodes.flake-compat.locked.rev}.tar.gz";
  sha256 = lock.nodes.${compat-flake}.locked.narHash;
}) { src = ./.; }).defaultNix
