{
  # Extend nixpkgs' lib with custom lib of this flake
  mkLib = nixpkgs: nixpkgs.lib.extend (final: prev: import ../nixpkgs/lib/default.nix { lib = prev; });

  # Apply config to nixpkgs
  mkPkgs = nixpkgs: config: import nixpkgs config;
}
