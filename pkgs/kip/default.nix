{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kip";
  version = "unstable-0.1.0-2025-05-02";

  src = fetchFromGitHub {
    owner = "oknozor";
    repo = "kip";
    rev = "73349333d24bd82f06f38f1ee5bc89b52ada1149";
    hash = "sha256-JDt7vsOPwCV9FYicDLMUfQWf1OZ0s3gVsMbsVVZJW6M=";
  };

  cargoHash = "sha256-LSanIO1jbA7b3RWIzfIJWWOhTBnkHpk6rPXDgetMU9A=";

  meta = with lib; {
    homepage = "https://github.com/oknozor/kip";
    description = "Personal dashboard in the command line interface";
    license = licenses.mit;
  };
})
