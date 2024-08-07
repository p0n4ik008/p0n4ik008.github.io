{ nixpkgs ? import <nixpkgs> {}, compiler ? "default", doBenchmark ? false }:

let

  inherit (nixpkgs) pkgs;

  myHaskellPackages = pkgs.haskellPackages.extend (hself: hsuper: {
    #hakyll = hsuper.callCabal2nix "hakyll" (pkgs.fetchFromGitHub {
    #  owner = "jaspervdj";
    #  repo = "hakyll";
    #  rev = "v4.16.0.0";
    #  sha256 = "sha256-liE4oH+WR6KDdTwMb2zlHsFxe0dPHNZa6HnZZFLNSdI=";
    #}) {};
  });

  f = { mkDerivation, base, directory, filepath, hakyll
      , hakyll-images, lib, process, time
      }:
      mkDerivation {
        pname = "site";
        version = "0.1.0.0";
        src = ./.;
        isLibrary = false;
        isExecutable = true;
        executableHaskellDepends = [
          base directory filepath hakyll hakyll-images process
          time
              (let
                src = builtins.fetchTarball {
                  url = "https://gitlab.com/dukzcry/funkshun/-/archive/0b71f4aaf3dcc8ee2918fbe04b4c269c89820704/funkshun-0b71f4aaf3dcc8ee2918fbe04b4c269c89820704.tar.gz";
                  sha256 = "0ll3d1k2hv3fd1n26gm76ypbkwdragj0ls7sgr94kqhmjwpr1cny";
                };
              in haskellPackages.callCabal2nix "hakyll-gallery" (src + "/hakyll-gallery") {})
        ];
        license = "unknown";
        hydraPlatforms = lib.platforms.none;
      };

  haskellPackages = if compiler == "default"
                       then myHaskellPackages
                       else pkgs.haskell.packages.${compiler};

  variant = if doBenchmark then pkgs.haskell.lib.doBenchmark else pkgs.lib.id;

  drv = variant (haskellPackages.callPackage f {});

in

  if pkgs.lib.inNixShell then drv.env else drv
