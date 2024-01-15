# Cookiecutter templates for your mama.
{ inputs, ... }: {
  flake.templates = {
    default = inputs.self.templates.basic-devshell;
    basic-devshell = {
      path = ../templates/basic-devshell;
      description = "Basic development shell template";
    };
    basic-overlay-flake = {
      path = ../templates/basic-overlay-flake;
      description = "Basic overlay as a flake";
    };
    sample-nixos-template = {
      path = ../templates/sample-nixos-template;
      description = "Simple sample Nix flake with NixOS and home-manager";
    };
    local-ruby-nix = {
      path = ../templates/local-ruby-nix;
      description = "Local Ruby app development with ruby-nix";
    };
  };
}
