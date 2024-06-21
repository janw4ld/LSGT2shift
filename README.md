# LSGT2shift

An [Interception Tools](https://gitlab.com/interception/linux/tools) plugin
that replaces the LSGT key (AKA 102nd key, AKA extra backslash, AKA extra ><)
with left shift.

![before](./README.d/layout-before.png)

![after](./README.d/layout-after.png)  
✅✅✅

European keyboards are weird.

## Install


- following interception tools'
  [install intstructions](https://gitlab.com/interception/linux/tools#installation)
  and using the following `udevmon.yaml`:

  ``` yaml
  - JOB: "intercept -g $DEVNODE | LSGT2shift | uinput -d $DEVNODE"
    DEVICE:
      EVENTS:
        EV_KEY: [KEY_102ND]
  ```


- with nix flakes:

  ```nix
  {
    inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      LSGT2shift = {
        url = "github:janw4ld/LSGT2shift";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };

    outputs = inputs: let
      system = "x86_64-linux";
      pkgs = inputs.nixpkgs.legacyPackages.${system};
    in {
      nixosConfigurations.hysm = inputs.nixpkgs.lib.nixosSystem {
        inherit pkgs;
        specialArgs = {inherit inputs;};

        modules = [
          ./hardware.nix
          ./configuration.nix
          inputs.LSGT2shift.nixosModules.${system}.default
          {janw4ld.LSGT2shift.enable = true;}
        ];
      };
    };
  }
  ```

> [!TIP]
> to use caps2esc with LSGT2shift, you can override interception-tools'
> `udevmonConfig` as follows:
>
> ```nix
> {
>   janw4ld.LSGT2shift.enable = true;
>   services.interception-tools.udevmonConfig = with pkgs; let
>     intercept = lib.getExe' interception-tools "intercept";
>     uinput = lib.getExe' interception-tools "uinput";
>     lsgt2shift = lib.getExe LSGT2shift;
>     caps2esc = lib.getExe interception-tools-plugins.caps2esc;
>   in
>     builtins.toJSON [{
>       JOB = "${intercept} -g $DEVNODE | ${lsgt2shift} | ${caps2esc} -m0 | ${uinput} -d $DEVNODE";
>       DEVICE.EVENTS.EV_KEY = ["KEY_CAPSLOCK" "KEY_ESC" "KEY_102ND"];
>     }];
> }
> ```

