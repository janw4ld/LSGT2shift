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

      pname = "LSGT2shift";
      drv = stdenv.mkDerivation {
        inherit pname;
        version = "v0.1.0";

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

        meta.mainProgram = pname;
      };
    in rec {
      devShells.default = (pkgs.mkShell.override {inherit stdenv;}) {
        inputsFrom = [drv];
        packages = [pkgs.clang-tools];
      };

      packages.default = packages.${pname};
      packages.${pname} = drv;

      overlays.default = overlays.${pname};
      overlays.${pname} = _: _: {${pname} = packages.default;};

      nixosModules.default = nixosModules.${pname};
      nixosModules.${pname} = {config, pkgs, lib, ...}: {
        options.janw4ld.LSGT2shift.enable =
          lib.mkEnableOption "LSGT2shift interception-tools plugin";

        config = lib.mkIf config.janw4ld.LSGT2shift.enable {
          nixpkgs.overlays = [overlays.default];
          services.interception-tools = {
            enable = lib.mkDefault true;
            plugins = [pkgs.${pname}];
            udevmonConfig = with pkgs; let
              intercept = lib.getExe' interception-tools "intercept";
              uinput = lib.getExe' interception-tools "uinput";
              lsgt2shift = lib.getExe pkgs.${pname};
            in
              lib.mkDefault (builtins.toJSON [{
                JOB = "${intercept} -g $DEVNODE | ${lsgt2shift} | ${uinput} -d $DEVNODE";
                DEVICE.EVENTS.EV_KEY = ["KEY_CAPSLOCK" "KEY_ESC" "KEY_102ND"];
              }]);
          };
        };
      };
    });
}
