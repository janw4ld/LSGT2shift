{
  nixConfig.bash-prompt-prefix = ''(LSGT2shift) '';
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system: let
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      stdenv = pkgs.llvmPackages.stdenv;

      drv = let
        pname = "LSGT2shift";
        version = "v0.1.0";
      in
        stdenv.mkDerivation {
          inherit pname version;

          src = with pkgs.lib.fileset;
            toSource {
              root = ./.;
              fileset = unions [
                ./LSGT2shift.c
                ./build.sh
              ];
            };

          buildPhase = ''$SHELL build.sh'';
          installPhase = ''install -Dm755 LSGT2shift $out/bin/LSGT2shift'';
        };
    in rec {
      packages.default = packages.LSGT2shift;
      packages.LSGT2shift = drv;

      devShells.default = (pkgs.mkShell.override {inherit stdenv;}) {
        inputsFrom = [drv];
        packages = [pkgs.clang-tools];
      };
    });
}
