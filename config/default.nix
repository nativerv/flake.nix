# Common configurations specific to this flake which don't fit into `lib`.
#
# Shared set of various settings that gets reused in `nixos/`, `home-manager/`
# etc.
#
# Also, stuff that i want easily accessible without the hussle of properly
# importing a (my custom 2-level) module.

{
  self,
  lib,
  flake,
  ...
}: let in {
  /* Default nixpkgs config */
  nixpkgs = { pkgs }: {
    allowUnfreePredicate = self.lib.unfreeWhiteList (with pkgs; [
      #hello-unfree
    ]);
  };
  groups = import ./groups.nix { inherit lib; };
  #users  = import ./users.nix { inherit lib; };
  backups = self.lib.fromJSONIfUnlockedOr {} "${flake}/sus/common/backups.json";
}
