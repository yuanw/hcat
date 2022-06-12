{
  description = "virtual environments";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.devshell.url = "github:numtide/devshell";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.gitignore = {
    url = "github:hercules-ci/gitignore.nix";
    # Use the same nixpkgs
    inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, devshell, flake-utils, gitignore }:

    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            devshell.overlay
            (final: prev: {
              haskellPackages = prev.haskellPackages.override {
                overrides = hself: hsuper: {
                  hcat = hself.callCabal2nix "hcat"
                    (gitignore.lib.gitignoreSource ./.) { };
                };
              };
              hcat = final.haskell.lib.justStaticExecutables
                final.haskellPackages.hcat;
            })
          ];
        };
        myHaskellEnv = (pkgs.haskellPackages.ghcWithHoogle (p:
          with p; [
            hcat
            cabal-install
            ormolu
            hlint
            hpack
            brittany
            haskell-language-server
          ]));

      in {
        packages = { hcat = pkgs.hcat; };
        defaultPackage = pkgs.hcat;
        checks = self.packages;
        devShell = pkgs.devshell.mkShell {
          name = "hcat";
          imports = [ (pkgs.devshell.extraModulesDir + "/git/hooks.nix") ];
          git.hooks.enable = true;
          git.hooks.pre-commit.text = "${pkgs.treefmt}/bin/treefmt";
          packages = [ myHaskellEnv pkgs.treefmt pkgs.nixfmt ];
        };
      });
}
