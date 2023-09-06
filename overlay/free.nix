# This overlay adds `free = false` to the firmware license,
# so that your nix system can be (hopefully) completely free by default.

final: prev: {
  lib = prev.lib.recursiveUpdate prev.lib {
    licenses.unfreeRedistributableFirmware =
      prev.lib.licenses.unfreeRedistributableFirmware // { free = false; };
  };
}
