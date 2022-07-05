let
  system1 =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG42LafAFOeh3oYz/cm6FXes0ss59/EOCXpGsYvhpI21";
  system2 =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHjRjAddjbyoM32tQhCjj8OrnqNBsXj+5D379iryupK+";
  system3 =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ4X7YXsEmMW3jP2dfU9l/KrF9jUZqN0sVXSvkag8VFH";
  systems = [ system1 system2 system3 ];

  user1 =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMclb6WPpYRoMVqCCzQcG2XQHczB6vaIEDIHqjVsyQJi";
  user2 =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBhrzY7tD0ZiGoA6nnfVxRQVQox0votQ2fuHz78LjNUD";
  user3 =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIytwsseYS6kV8ldiUV767C2Gy7okxckdDRW4aA3q/Ku";
  user4 =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGtn+t2D7clY1U1rzKcSCBJjNbuJzbRArEiM3soyFcnv";
  users = [ user1 user2 user3 user4 ];
in {
  "archive/borg-patterns".publicKeys = users ++ systems;
  "archive/borg-patterns-local".publicKeys = users ++ systems;
  "archive/borg-ssh-key".publicKeys = systems;
  "archive/password".publicKeys = users ++ systems;
  "archive/key".publicKeys = users ++ systems;
}
