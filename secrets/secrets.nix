let
  system1 =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG42LafAFOeh3oYz/cm6FXes0ss59/EOCXpGsYvhpI21";

  user1 =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMclb6WPpYRoMVqCCzQcG2XQHczB6vaIEDIHqjVsyQJi";
  user2 =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBhrzY7tD0ZiGoA6nnfVxRQVQox0votQ2fuHz78LjNUD";
  user3 =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIytwsseYS6kV8ldiUV767C2Gy7okxckdDRW4aA3q/Ku";
  user4 =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGtn+t2D7clY1U1rzKcSCBJjNbuJzbRArEiM3soyFcnv";
in {
  "archive/password".publicKeys = [ system1 user3 user4 ];
  "archive/borgmatic.json".publicKeys = [ system1 user3 user4 ];
}
