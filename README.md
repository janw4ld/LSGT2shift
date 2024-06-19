# LSGT2shift

An [Interception Tools](https://gitlab.com/interception/linux/tools) plugin
that replaces the LSGT key (AKA 102nd key) with left shift. European keyboards
are weird.

## Install

## Usage

`LSGT2shift` is an [Interception Tools](https://gitlab.com/interception/linux/tools)
plugin. Refer to that project's README for information on installation and
usage. An example `udevmon` configuration:

``` yaml
- JOB: "intercept -g $DEVNODE | casp2esc -m0 | LSGT2shift | uinput -d $DEVNODE"
  DEVICE:
    EVENTS:
      EV_KEY:
       - KEY_CAPSLOCK
       - KEY_ESC
       - KEY_102ND
```

