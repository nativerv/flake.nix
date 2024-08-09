{ self, inputs, lib, flake, ... }: rec {
  free = import ./free.nix;
  nixpak = import ./nixpak.nix { inherit (inputs) nixpak; };
  wrap-packages = import ./wrap-packages.nix { inherit self; };
  flatpak-debug = final: prev: {
    # WARNING: untested. working version commented below
    flatpak = prev.callPackage "${flake}/package/flatpak" {};
    #flatpak = prev.flatpak.overrideAttrs (o: {
    #  patches = (o.patches or []) ++ [ ../package/flatpak/debug-bwrap-args.patch ];
    #});
  };
  default = lib.composeManyExtensions [ free nixpak wrap-packages ];
}
