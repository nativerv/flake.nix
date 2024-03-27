{ self, inputs, lib, ... }: rec {
  free = import ./free.nix;
  nixpak = import ./nixpak.nix { inherit (inputs) nixpak; };
  default = lib.composeManyExtensions [ free nixpak ];
}
