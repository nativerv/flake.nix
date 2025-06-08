# This package group provides linux kernels that are
# compatible with the ZFS kernel module
# Credit: https://web.archive.org/web/20240924080706/https://wiki.nixos.org/wiki/ZFS
{ linuxKernel, lib, kernelModuleAttribute, ... }:
with builtins;
with lib;
let
  # Filter out the compatible kernels
  compatible = pipe linuxKernel.packages [
    (filterAttrs (
      name: kernelPackages:
      # (tryEval kernelPackages).success
      # && kernelPackages ? kernel
      # && kernelPackages.kernel.pname == "linux"
      # && !kernelPackages.zfs.meta.broken

      (builtins.match "linux_[0-9]+_[0-9]+" name) != null
      && (builtins.tryEval kernelPackages).success
      && (!kernelPackages.${kernelModuleAttribute}.meta.broken)
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

# let
#   zfsCompatibleKernelPackages = lib.filterAttrs (
#     name: kernelPackages:
#     (builtins.match "linux_[0-9]+_[0-9]+" name) != null
#     && (builtins.tryEval kernelPackages).success
#     && (!kernelPackages.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken)
#   ) pkgs.linuxKernel.packages;
#   latestKernelPackage = lib.last (
#     lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
#       builtins.attrValues zfsCompatibleKernelPackages
#     )
#   );
# in
# {
#   # Note this might jump back and forth as kernels are added or removed.
#   boot.kernelPackages = latestKernelPackage;
# }
