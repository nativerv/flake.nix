{
  flake,
  self,
  inputs,

  system ? "x86_64-linux",
  ...
}: let
  nixpkgs = inputs.nixpkgs-unstable;
  pkgs = import nixpkgs {
    inherit system;
    overlays = [ self.overlays.default ];
    config = self.config.nixpkgs;
  };

  # Use folder name as name of this system
  name = nixpkgs.lib.pipe ./. [
    (builtins.toString)
    (builtins.baseNameOf)
  ];

in nixpkgs.lib.nixosSystem {
  inherit pkgs;
  modules = [
    ({ networking.hostName = name; })
    (import ./${name}.nix { inherit flake self inputs; })
  ];
}
