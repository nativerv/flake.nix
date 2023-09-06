# Overlay for nixpkgs' lib.

{ lib, ... }: rec {
  # Make a whitelist predicate for allowUnfreePredicate
  # Useful because package 'names' and actual package names in `nixpkgs.pkgs` can differ
  unfreeWhiteList = list: pkg: builtins.elem (lib.getName pkg) (map lib.getName list);

  # For knowing if the repo is locked
  isLocked = !(builtins.readFile ../../locked == "0");
  ifUnlocked = lib.optional (!isLocked);
}
