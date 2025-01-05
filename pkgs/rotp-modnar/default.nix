{
  lib,
  rotp,
  fetchFromGitHub,
}:

rotp.overrideAttrs (finalAttrs: prevAttrs: {
  src = fetchFromGitHub {

  };
})
