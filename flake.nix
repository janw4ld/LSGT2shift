{
  nixConfig.bash-prompt-prefix = ''(LSGT2shift) '';
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system: let
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      stdenv = pkgs.pkgsMusl.stdenv;

      pname = "lsgt2shift";
      drv = stdenv.mkDerivation {
        inherit pname;
        version = "v1.0.0";

        src = with pkgs.lib.fileset;
          toSource {
            root = ./.;
            fileset = unions [
              ./build.sh
              (fileFilter (file: file.hasExt "c" || file.hasExt "h") ./.)
            ];
          };

        buildPhase = ''$SHELL build.sh'';
        installPhase = ''install -Dm755 ${pname} $out/bin/${pname}'';

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
      overlays.${pname} = _: prev: {
        interception-tools-plugins =
          prev.interception-tools-plugins // {${pname} = packages.default;};
      };

      nixosModules.default = nixosModules.${pname};
      nixosModules.${pname} = {
        config,
        pkgs,
        lib,
        ...
      }: {
        options.janw4ld.lsgt2shift.enable =
          lib.mkEnableOption "enable lsgt2shift interception-tools plugin";

        config = lib.mkIf config.janw4ld.lsgt2shift.enable {
          nixpkgs.overlays = [overlays.default];
          services.interception-tools = {
            enable = lib.mkDefault true;
            udevmonConfig = with pkgs; let
              intercept = lib.getExe' interception-tools "intercept";
              uinput = lib.getExe' interception-tools "uinput";
              lsgt2shift = lib.getExe pkgs.interception-tools-plugins.${pname};
            in
              lib.mkDefault (builtins.toJSON [
                {
                  JOB = "${intercept} -g $DEVNODE | ${lsgt2shift} | ${uinput} -d $DEVNODE";
                  DEVICE.EVENTS.EV_KEY = ["KEY_102ND"];
                }
              ]);
          };
        };
      };
    });
}
