{ stdenv, lib, rustPlatform, fetchFromGitHub, perl, pkg-config, openssl }:

let
  version = "unstable-2022-03-01";
  homepage = "https://github.com/chipsenkbeil/distant";
  license = lib.licenses.mit;

  repo = fetchFromGitHub {
    owner = "chipsenkbeil";
    repo = "distant";
    rev = "f46eeea8d54c6527e590a8da279a6fb4783bfd9f";
    sha256 = "sha256-AVhOs7qqtqz3TOsJiE6mUzMz2zR3qGBYnW9Lwm/JStk=";
  };
in lib.recurseIntoAttrs {
  distant = rustPlatform.buildRustPackage rec {
    inherit version;
    pname = "distant";

    src = repo;
    cargoSha256 = "sha256-KCw0rujcQq3VAWMt54aoa/B61rcSKn2D1gwROAfAckE=";

    # We'll just tell to use the system's openssl to build openssl-sys.
    OPENSSL_NO_VENDOR = 1;
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ perl openssl ];

    meta = with lib; {
      inherit homepage license;
      description = "Remotely edit files and run programs";
    };
  };

  distant-lua = rustPlatform.buildRustPackage rec {
    inherit version;
    pname = "distant-lua";

    src = repo;
    cargoSha256 = "sha256-Cv2obK4m8eCXxpoX0zb1mb9lOdRJzMKRUNPr4dopeFw=";

    OPENSSL_NO_VENDOR = 1;
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ perl openssl ];

    preBuild = "cd distant-lua";
    postBuild = "cd ..";

    meta = with lib; {
      inherit homepage license;
      description = "Lua bindings for Distant";
    };
  };
}
