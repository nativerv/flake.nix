{
  flake,
  self,
  inputs,

  system ? "x86_64-linux",
  ...
}: let
  # WARNING: there may be consiquences to hardcoding the `nixpkgs` flake here. At least: it's API is unstable
  inherit (inputs.nixpkgs.lib) nixosSystem;
  inherit (self.legacyPackages."${system}") pkgs lib;
  name = lib.pipe ./. [
    (builtins.toString)
    (builtins.baseNameOf)
  ];
in nixosSystem {
  inherit lib pkgs system;
  modules = [
    ({ networking.hostName = name; })
    (import ./${name}.nix { inherit flake self inputs; })
  ];
}
