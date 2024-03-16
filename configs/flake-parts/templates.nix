# Cookiecutter templates for your mama.
{ inputs, ... }: {
  flake.templates = {
    default = inputs.self.templates.basic-devshell;
    basic-devshell = {
      path = ../../templates/basic-devshell;
      description = "Basic development shell template";
    };
    basic-nix-cpp-app = {
      path = ../../templates/basic-nix-cpp-app;
      description = "Basic Nix program with C++ API";
    };
    basic-nix-module-flake = {
      path = ../../templates/basic-nix-module-flake;
      description = "Basic Nix module flake template";
    };
    basic-overlay-flake = {
      path = ../../templates/basic-overlay-flake;
      description = "Basic overlay as a flake";
    };
    rust-app = {
      path = ../../templates/rust-app;
      description = "Rust app scaffolding";
    };
    sample-nixos-template = {
      path = ../../templates/sample-nixos-template;
      description = "Simple sample Nix flake with NixOS and home-manager";
    };
    local-ruby-nix = {
      path = ../../templates/local-ruby-nix;
      description = "Local Ruby app development with ruby-nix";
    };
  };
}
