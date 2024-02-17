// A nifty little app for resolving flakerefs to the locked input. Because the
// C++ API is mostly unstable, this is confirmed to be working with Nix v2.18.2
// just for reference.

#include <iostream>

#include <nlohmann/json.hpp>

#include <nix/flake/flake.hh>
#include <nix/shared.hh>
#include <nix/store-api.hh>

int main(int argc, char *argv[]) {
  nix::initNix();

  auto store = nix::openStore();

  try {
    nix::FlakeRef originalRef =
        nix::parseFlakeRef(argv[1], std::nullopt, true, false);
    auto [tree, lockedInput] = originalRef.input.fetch(store);
    std::cout << lockedInput.to_string() << std::endl;
  } catch (std::exception &e) {
    std::cerr << e.what() << std::endl;
    return EXIT_SUCCESS;
  }

  return EXIT_SUCCESS;
}
