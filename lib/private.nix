# This is just a library intended solely for this flake.
# It is expected to use the nixpkgs library with `lib/default.nix`.
{ lib }:

rec {
  getSecret = path: ../secrets/${path};

  getUsers = type: users:
    let
      userModules = lib.filesToAttr ../users/${type};
      invalidUsernames = [ "config" "modules" ];

      users' = lib.filterAttrs (n: _: !lib.elem n invalidUsernames && lib.elem n users) userModules;
      userList = lib.attrNames users';

      nonExistentUsers = lib.filter (name: !lib.elem name userList) users;
    in lib.trivial.throwIfNot ((lib.length nonExistentUsers) == 0)
      "there are no users ${lib.concatMapStringsSep ", " (u: "'${u}'") nonExistentUsers} from ${type}"
      (r: r) users';

  getUser = type: user:
    lib.getAttr user (getUsers type [ user ]);
}
