{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.foo-dogsquared = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
}
