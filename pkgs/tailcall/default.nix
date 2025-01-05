{ rustPlatform, lib, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "tailcall";
  version = "0.129.0";

  src = fetchFromGitHub {
    owner = "tailcallhq";
    repo = "tailcall";
    rev = "v${version}";
    hash = "sha256-tTj1hugq6a6rAKwUsS072pCizsB/BYaBlu8OWGYKNsk=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "genai-0.1.7-wip" = "sha256-peqM0rBLnL4F0M6o8CO/+ttv9eOLV4VkDEy2e4x7dn0=";
      "htpasswd-verify-0.3.0" = "sha256-GbkY590xWEZ+lVT9nffs4HIRW6CwBjll4rGIk27waxo=";
      "posthog-rs-0.2.3" = "sha256-1HxOEzc8GROStxuxG0cfCNa4iA04sCD7jD6uWT5bl2o=";
      "serde_json_borrow-0.7.0" = "sha256-UcgIWjdSCkYRYxEcWbwQs+BxX41ITqkvFSFtzEJchVk=";
    };
  };

  meta = with lib; {
    homepage = "https://tailcall.run";
    description = "GraphQL runtime";
    license = licenses.asl20;
    mainProgram = "tailcall";
  };
}
