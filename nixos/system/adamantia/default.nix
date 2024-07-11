{
  flake,
  self,
  inputs,

  # NOTE: Change this for other platforms (like `aarch64-linux`)
  # Import this file with `system` argument passed to reuse this file for other
  # platforms.
  system ? "x86_64-linux",
  ...
}: let
  # INFO: `nixpkgs-flake`: inserted with an overlay into `self.legacyPackages`.
  inherit (self.legacyPackages."${system}") pkgs nixpkgs-flake;

  # Use folder name as name of this system
  name = builtins.baseNameOf ./.;

in nixpkgs-flake.lib.nixosSystem {
  inherit pkgs;
  modules = [
    ({ networking.hostName = name; })
    (import ./${name}.nix { inherit flake self inputs; })
  ];
}
