# LSGT2shift

An [Interception Tools](https://gitlab.com/interception/linux/tools) plugin
that replaces the LSGT key (AKA 102nd key, AKA extra backslash, AKA extra ><)
with left shift.

![before](./README.d/layout-before.png)

![after](./README.d/layout-after.png)  
✅✅✅

European keyboards are weird.

## Installation

> [!NOTE]
> If you don't already use `interception-tools`, you'd be much better off just
> just adding `setxkbmap -option lv2:lsgt_switch` to your `~/.profile`

### install on nixos with flakes:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    lsgt2shift = {
      url = "github:janw4ld/lsgt2shift";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    system = "x86_64-linux";
    pkgs = inputs.nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations.hysm = inputs.nixpkgs.lib.nixosSystem {
      inherit pkgs;
      modules = [
        ./hardware.nix
        ./configuration.nix
        inputs.lsgt2shift.nixosModules.${system}.default
        {janw4ld.lsgt2shift.enable = true;}
      ];
    };
  };
}
```

> [!TIP]
> to use caps2esc with lsgt2shift, you can override interception-tools'
> `udevmonConfig` by replacing the config snippet by the following:
>
> ```nix
> {
>   janw4ld.lsgt2shift.enable = true;
>   services.interception-tools.udevmonConfig = with pkgs; let
>     intercept = lib.getExe' interception-tools "intercept";
>     uinput = lib.getExe' interception-tools "uinput";
>     lsgt2shift = lib.getExe interception-tools-plugins.lsgt2shift;
>     caps2esc = lib.getExe interception-tools-plugins.caps2esc;
>   in
>     builtins.toJSON [{
>       JOB = "${intercept} -g $DEVNODE | ${lsgt2shift} | ${caps2esc} -m0 | ${uinput} -d $DEVNODE";
>       DEVICE.EVENTS.EV_KEY = ["KEY_CAPSLOCK" "KEY_ESC" "KEY_102ND"];
>     }];
> }
> ```

### install from source:

1. clone the repository
1. run `build.sh` to compile with clang or `CC=gcc ./build.sh` for gcc
1. add the `lsgt2shift` binary to your `PATH`
1. follow interception tools'
    [install intstructions](https://gitlab.com/interception/linux/tools#installation)
    then use the following `udevmon.yaml` file:

    ``` yaml
    - JOB: "intercept -g $DEVNODE | lsgt2shift | uinput -d $DEVNODE"
      DEVICE:
        EVENTS:
          EV_KEY: [KEY_102ND]
    ```

