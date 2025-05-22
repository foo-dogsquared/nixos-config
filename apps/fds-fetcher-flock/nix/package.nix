{ lib, buildGoModule, pkg-config, fontconfig, curl, openssl, installShellFiles }:

buildGoModule (finalAttrs: {
  pname = "fds-flock-of-fetchers";
  version = "0.1.0";

  nativeBuildInputs = [ pkg-config installShellFiles ];
  buildInputs = [
    fontconfig
    curl
    openssl
  ];

  src = lib.cleanSource ../.;

  # This uses a lot of network checks so no.
  checkFlags =
    let
      testCases = [ ];
    in
      lib.singleton "-skip=^${lib.concatStringsSep "$|^" testCases}$";

  postInstall = ''
    ln -sf $out/bin/${finalAttrs.pname} $out/bin/ffof

    installShellCompletion --cmd ${finalAttrs.pname} \
      --bash <($out/bin/${finalAttrs.pname} completion bash) \
      --zsh <($out/bin/${finalAttrs.pname} completion zsh) \
      --fish <($out/bin/${finalAttrs.pname} completion fish)
  '';

  vendorHash = "sha256-4/w2pzqPgy+vsVaq4gDhRLsVlrm1WAj2LEgNiUcp1vk=";

  meta = with lib; {
    description = "foodogsquared's custom fetcher program specifically suited for the custom Nix fetcher functions";
    license = with licenses; [ bsd3 ];
    mainProgram = finalAttrs.pname;
    changelog = ../CHANGELOG.md;
  };
})
