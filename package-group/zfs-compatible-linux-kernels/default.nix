# This package group provides linux kernels that are
# compatible with the ZFS kernel module
# Credit: https://web.archive.org/web/20240924080706/https://wiki.nixos.org/wiki/ZFS
{ linuxKernel, lib, ... }:
with builtins;
with lib;
let
  # Filter out the compatible kernels
  compatible = pipe linuxKernel.packages [
    (filterAttrs (
      _: kernelPackages:
      (tryEval kernelPackages).success
      && kernelPackages ? kernel
      && kernelPackages.kernel.pname == "linux"
      && !kernelPackages.zfs.meta.broken
    ))
    attrsToList
    (sort (a: b: (versionOlder a.value.kernel.version b.value.kernel.version)))
  ];
  all = map ({ value, ... }: value) compatible;
# Expose compatible & add alias for latest
in (listToAttrs compatible) // {
  latest = last all;
  # Also expose sorted list
  inherit all;
}
