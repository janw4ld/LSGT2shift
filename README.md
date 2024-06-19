# LSGT2shift

An [Interception Tools](https://gitlab.com/interception/linux/tools) plugin
that replaces the LSGT key (AKA 102nd key) with left shift. European keyboards
are weird.

## Install

## Usage

example setups:

### using the nixos module:

```nix
{inputs, ...}: {
  imports = [inputs.lsgt2shift.nixosModules.${system}.default];
  janw4ld.LSGT2shift.enable = true;
}
```

### composing caps2esc with LSGT2shift:

```nix
{pkgs, lib, inputs, ...}: {
  imports = [inputs.lsgt2shift.nixosModules.${system}.default];
  janw4ld.LSGT2shift.enable = true;
  services.interception-tools.udevmonConfig = with pkgs; let
    intercept = lib.getExe' interception-tools "intercept";
    uinput = lib.getExe' interception-tools "uinput";
    lsgt2shift = lib.getExe LSGT2shift;
    caps2esc = lib.getExe interception-tools-plugins.caps2esc;
  in
    builtins.toJSON [{
      JOB = "${intercept} -g $DEVNODE | ${lsgt2shift} | ${caps2esc} -m0 | ${uinput} -d $DEVNODE";
      DEVICE.EVENTS.EV_KEY = ["KEY_CAPSLOCK" "KEY_ESC" "KEY_102ND"];
    }];
}
```

### `udevmon.yaml`:

``` yaml
- JOB: "intercept -g $DEVNODE | LSGT2shift | uinput -d $DEVNODE"
  DEVICE:
    EVENTS:
      EV_KEY: [KEY_102ND]
```

