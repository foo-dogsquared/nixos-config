# Bundling everything for my fullstack (in JS) webdev needs.
{ mkShell, nodejs, bun, esbuild, pnpm }:

mkShell {
  packages = [
    nodejs
    bun
    esbuild
    pnpm
  ];
}
